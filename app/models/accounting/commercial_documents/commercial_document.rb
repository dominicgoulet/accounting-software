# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_documents
#
#  id                :uuid             not null, primary key
#  amount_due        :decimal(, )
#  amount_paid       :decimal(, )
#  currency          :string
#  date              :date
#  due_date          :date
#  exchange_rate     :decimal(, )
#  number            :string
#  status            :string
#  subtotal          :decimal(, )
#  taxes_amount      :decimal(, )
#  taxes_calculation :string
#  total             :decimal(, )
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :uuid
#  contact_id        :uuid
#  organization_id   :uuid
#
class CommercialDocument < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  belongs_to :contact
  belongs_to :account, optional: true
  has_many :outgoing_emails, as: :related_object, dependent: :destroy
  has_many_attached :attached_files, dependent: :destroy
  has_many :lines, foreign_key: 'commercial_document_id', class_name: 'CommercialDocumentLine', dependent: :destroy, inverse_of: :document
  has_many :taxes, foreign_key: 'commercial_document_id', class_name: 'CommercialDocumentTax', dependent: :destroy, inverse_of: :document
  has_many :payments, foreign_key: 'commercial_document_id', class_name: 'CommercialDocumentPayment', dependent: :destroy, inverse_of: :document
  has_many :bank_transaction_rule_matches, through: :organization, inverse_of: :matched_document, dependent: :destroy
  has_many :transactions, through: :bank_transaction_rule_matches, source: :bank_transaction
  has_many :journal_entries, as: :journalable, dependent: :destroy

  # Scopes
  default_scope { order('date desc') }
  scope :outstanding, -> { where('amount_due > 0') }

  # Validations
  validates :organization, presence: true
  validates :contact, presence: true
  validates :date, presence: true
  validates :due_date, presence: true, if: ->(obj) { obj.expirable? }
  validates :account, presence: true, if: ->(obj) { obj.accountable? }

  # Enumerations
  enumerize :taxes_calculation, in: %i[inclusive exclusive], default: :inclusive

  # Callbacks
  after_initialize :set_defaults
  before_save :update_calculated_fields
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :lines, allow_destroy: true, reject_if: ->(c) { c[:item_id].blank? }
  accepts_nested_attributes_for :taxes, allow_destroy: true, reject_if: lambda { |c|
                                                                          c[:id].blank? && c[:sales_tax_id].blank?
                                                                        }

  # Hotwired
  # broadcasts_to ->(obj) { [obj.organization, :commercial_documents] },
  #   inserts_by: :prepend,
  #   partial: 'commercial_documents/kanban_item',
  #   locals: { document: self }

  after_create_commit do
    broadcast_append_to([self.organization, :commercial_documents, :kanban], target: 'commercial_documents', partial: "commercial_documents/kanban_item", locals: { document: self })
    broadcast_append_to([self.organization, :commercial_documents, :datatable], target: 'commercial_documents', partial: "commercial_documents/datatable_item", locals: { document: self })
  end

  after_update_commit do
    broadcast_replace_to([self.organization, :commercial_documents, :kanban], target: self, partial: "commercial_documents/kanban_item", locals: { document: self })
    broadcast_replace_to([self.organization, :commercial_documents, :datatable], target: self, partial: "commercial_documents/datatable_item", locals: { document: self })
  end

  after_destroy_commit do
    broadcast_remove_to([self.organization, :commercial_documents, :kanban], target: self)
    broadcast_remove_to([self.organization, :commercial_documents, :datatable], target: self)
  end

  #
  # Todo
  #

  def expirable?
    %w[Bill PurchaseOrder Invoice Estimate].include? type
  end

  def accountable?
    %w[Deposit Expense].include? type
  end

  def payable?
    %w[Bill Invoice].include? type
  end

  def transactionable?
    %w[Expense Deposit].include? type
  end

  #
  # Calculations
  #

  def update_calculated_fields
    self.date = Date.today if date.nil?
    self.due_date = Date.today if expirable? && due_date.nil?

    update_subtotal
    update_taxes
    update_total

    check_and_balance_subtotals_inclusive_taxes

    update_payments if payable?
    update_status

    true
  end

  private

  def set_defaults
    # self.date = Date.today if date.nil?
    self.due_date = Date.today + 30 if due_date.nil?
  end

  def check_and_balance_subtotals_inclusive_taxes
    expected_total = 0

    lines.each do |line|
      expected_total += line.expected_total
    end

    return unless expected_total != total && taxes.size.positive?

    max_tax_rate = taxes.first.sales_tax.rate
    tax_to_adjust = taxes.first

    taxes.each do |tax|
      if tax.sales_tax.rate > max_tax_rate
        max_tax_rate = tax.sales_tax.rate
        tax_to_adjust = tax
      end
    end

    tax_to_adjust.amount += expected_total - total
    tax_to_adjust.save

    self.taxes_amount += expected_total - total
    update_total
  end

  def update_taxes
    applied_taxes = []

    # 1) Fetch all taxes applied to lines
    lines.each do |line|
      line.taxes.each do |line_tax|
        applied_taxes << line_tax.sales_tax_id unless line_tax._destroy
      end
    end

    # 2) Add taxes that are not in document but present in lines
    applied_taxes.uniq.each do |tax|
      taxes.build(sales_tax_id: tax, calculate_from_rate: true) unless taxes.map(&:sales_tax_id).include? tax
    end

    self.taxes_amount = 0

    taxes.each do |tax|
      if applied_taxes.include? tax.sales_tax_id
        # 4) Update amount when set to calculate_from_rate
        tax.calculate_from_rate = true unless tax.amount.present?

        if tax.calculate_from_rate?
          # WRONG : If lines don't share the same taxes, it calculates the total anyways
          amount = (subtotal * tax.sales_tax.rate / 100.0).round(2)
          tax.amount = amount
        end

        self.taxes_amount += tax.amount
      else
        # 3) Remove taxes from document that are not in lines
        tax.destroy
      end
    end
  end

  def update_subtotal
    self.subtotal = 0

    lines.each do |line|
      line.update_calculated_fields
      self.subtotal += line.subtotal || 0
    end
  end

  def update_total
    self.total = self.subtotal + self.taxes_amount
  end

  def update_payments
    self.amount_paid = 0

    payments.each do |payment|
      self.amount_paid += payment.amount || 0
    end

    self.amount_due = total - self.amount_paid
  end

  def update_status
    return unless payable?

    if self.amount_paid.positive?
      self.status = 'partial' if amount_due.positive?
      self.status = 'paid' if amount_due <= 0
    elsif expirable? && due_date < Date.today
      self.status = 'late'
    end
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
