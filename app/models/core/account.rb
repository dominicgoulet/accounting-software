# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                :uuid             not null, primary key
#  account_type      :string
#  accountable_type  :string
#  classification    :string
#  currency          :string
#  current_balance   :decimal(, )
#  description       :string
#  display_name      :string
#  full_path         :string
#  generated         :boolean          default(FALSE)
#  internal_code     :string
#  name              :string
#  reference         :integer
#  starting_balance  :decimal(, )
#  status            :string
#  system            :boolean          default(FALSE)
#  total_credit      :decimal(, )
#  total_debit       :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  accountable_id    :uuid
#  organization_id   :uuid
#  parent_account_id :uuid
#
class Account < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  belongs_to :parent_account, class_name: 'Account', optional: true
  belongs_to :accountable, polymorphic: true, optional: true
  has_many :account_taxes, dependent: :destroy
  has_many :sales_taxes, through: :account_taxes
  has_many :journal_entry_lines
  has_many :child_accounts, class_name: 'Account', foreign_key: 'parent_account_id', dependent: :nullify

  # Scopes
  default_scope do
    order(Arel.sql(%(
      CASE classification
      WHEN 'asset' THEN 1
      WHEN 'liability' THEN 2
      WHEN 'equity' THEN 3
      WHEN 'income' THEN 4
      WHEN 'expense' THEN 5
      ELSE 999
      END ASC,
      full_path ASC
    )))
  end

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validate :parent_account_cannot_be_itself_or_a_child

  # Enumerations
  enumerize :classification, in: %i[asset liability equity income expense], default: :asset
  enumerize :status, in: %i[active pending inactive], default: :active

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true
  before_save :update_calculated_fields
  after_save :update_child_accounts
  before_destroy :update_child_accounts

  # Hotwired
  # broadcasts_to ->(account) { [account.organization, :accounts] }, inserts_by: :prepend, partial: 'settings/accounts/account'
  broadcasts_to lambda { |account|
                  [account.organization, account.classification, :accounts]
                }, inserts_by: :prepend, partial: 'settings/accounts/account'

  after_commit :send_html_counter, on: %i[create update destroy]
  def send_html_counter
    Account.classification.each_value do |classification|
      broadcast_update_to [organization, :filters],
                          target: "filters-#{classification}-count",
                          html: organization.accounts.where(classification:).size
    end
  end

  #
  # Parent
  #

  def parent_accounts
    parents = []

    acc = parent_account

    while acc
      parents << acc

      acc = acc.parent_account
    end

    parents.reverse
  end

  private

  def update_calculated_fields
    credit_sum = journal_entry_lines.sum(:credit)
    debit_sum = journal_entry_lines.sum(:debit)
    acc_type = 'Custom account'

    if system? && !generated?
      acc_type = 'System account'
    elsif accountable_type.present?
      acc_type = accountable_type.underscore.humanize
    end

    self.display_name = [reference, name].join(' ')
    self.account_type = acc_type
    self.full_path = (parent_accounts.map(&:display_name) + [display_name]).join('.')
    self.current_balance = (starting_balance || 0) + debit_sum - credit_sum
    self.total_credit = credit_sum
    self.total_debit = debit_sum
  end

  def parent_account_cannot_be_itself_or_a_child
    return unless parent_account.present?

    if parent_account == self
      errors.add(:parent_account, 'cannot be self.')
      throw(:abort)
    elsif parent_account.parent_account.present?
      acc = parent_account.parent_account

      while acc.present?
        if acc == self
          errors.add(:parent_account, 'cannot be a child of this account.')
          throw(:abort)
        end

        acc = acc.parent_account
      end
    end

    true
  end

  def update_child_accounts
    child_accounts.each(&:save)
  end

  def in_use
    return true if journal_entry_lines.any?
    return true if organization.items.where(income_account: self).any?
    return true if organization.items.where(expense_account: self).any?
  end

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true if !system? && !in_use

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
