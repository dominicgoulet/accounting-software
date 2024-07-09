# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_accounts
#
#  id                       :uuid             not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank_account_id          :uuid
#  bank_transaction_rule_id :uuid
#
class BankTransactionRuleAccount < ApplicationRecord
  # Associations
  belongs_to :bank_transaction_rule
  belongs_to :bank_account

  # Validations
  validates :bank_transaction_rule, presence: true
  validates :bank_account, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
