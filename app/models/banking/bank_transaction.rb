# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transactions
#
#  id                       :uuid             not null, primary key
#  authorized_date          :date
#  authorized_datetime      :datetime
#  check_number             :string
#  credit                   :decimal(, )
#  date                     :date
#  datetime                 :datetime
#  debit                    :decimal(, )
#  iso_currency_code        :string
#  merchant_name            :string
#  name                     :string
#  payment_channel          :string
#  pending                  :boolean
#  status                   :string
#  transaction_code         :string
#  unofficial_currency_code :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :string
#  bank_account_id          :uuid
#  category_id              :string
#  transaction_id           :string
#
class BankTransaction < ApplicationRecord
  include Rails.application.routes.url_helpers
  extend Enumerize

  # Associations
  belongs_to :bank_account
  has_many :bank_transaction_transactionables, dependent: :destroy
  has_many :bank_transaction_rule_matches, dependent: :destroy

  # Validations
  validates :bank_account, presence: true

  # Enumerations
  enumerize :status, in: %i[imported matched described approved rejected], default: :imported

  # Callbacks
  before_save :update_bank_transaction
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :bank_transaction_transactionables, allow_destroy: true

  # Scopes
  default_scope { order('date desc') }
  scope :imported, -> { where(status: 'imported') }
  scope :matched, -> { where(status: 'matched') }
  scope :described, -> { where(status: 'described') }

  # Hotwire
  broadcasts_to lambda { |bank_transaction|
                  [bank_transaction.bank_account.organization, :bank_transactions]
                }, inserts_by: :prepend

  after_commit :send_html_counter, on: %i[create update destroy]
  def send_html_counter
    BankTransaction.status.each_value do |status|
      broadcast_update_to [bank_account.organization, bank_account, :bank_transactions_status_filter],
                          target: "filters-bank-transaction-#{status}-count",
                          html: bank_account.bank_transactions.where(status:).size
    end
  end

  #
  # Shorthands
  #

  def debit?
    debit.positive?
  end

  def credit?
    !debit?
  end

  def account
    bank_account.account
  end

  #
  # Rules
  #

  def match_rule!(rule)
    bank_account.organization.bank_transaction_rule_matches.find_or_create_by(
      bank_transaction_id: id,
      bank_transaction_rule_id: rule.id
    )

    update(status: :matched)
  end

  def match_document!(document)
    bank_account.organization.bank_transaction_rule_matches.find_or_create_by(
      bank_transaction_id: id,
      matched_document: document
    )

    update(status: :matched)
  end

  def matches?
    bank_transaction_rule_matches.any?
  end

  #
  # Status
  #

  def reset
    update(status: :imported)
  end

  def approve
    update(status: :approved)
  end

  def reject
    update(status: :rejected)
  end

  def review
    update(status: :described)
  end

  #
  # Actions
  #

  def actions
    {
      imported: [
        {
          route: new_bank_transaction_transactionable_path(self),
          label: 'Describe',
          turbo_frame: :modal,
          primary: true
        },
        {
          route: new_bank_transaction_rule_path(bank_transaction_id: id),
          label: 'Create rule',
          turbo_frame: :modal
        }
      ],
      matched: [
        {
          route: bank_transaction_rule_matches.any? ? apply_bank_transaction_rule_match_path(bank_transaction_rule_matches.first&.id) : nil,
          label: 'Apply rule',
          turbo_method: :patch,
          primary: true
        },
        {
          route: bank_transaction_rule_matches.any? ? bank_transaction_rule_match_path(bank_transaction_rule_matches.first&.id) : nil,
          label: 'Cancel',
          turbo_method: :delete,
          turbo_frame: :modal
        }
      ],
      described: [
        {
          route: approve_bank_transaction_path(self),
          label: 'Approve',
          turbo_method: :patch,
          primary: true
        },
        {
          route: if bank_transaction_transactionables.any?
                   polymorphic_path([:edit,
                                     bank_transaction_transactionables.first.transactionable])
                 end,
          label: 'Edit details',
          turbo_frame: :modal
        }
      ]
    }[status.to_sym] || []
  end

  private

  def update_bank_transaction
    self.status = :described if bank_transaction_transactionables.size.positive? && status.imported?

    return unless bank_transaction_transactionables.empty? && (status.described? || status.approved?)

    self.status = if bank_transaction_rule_matches.any?
                    :matched
                  else
                    :imported
                  end

    # self.amount = bank_transaction_transactionables.sum { |btt| btt.amount || 0 }
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
