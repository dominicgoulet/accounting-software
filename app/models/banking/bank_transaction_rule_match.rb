# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_matches
#
#  id                         :uuid             not null, primary key
#  matched_document_type      :string
#  matched_rule_internal_name :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  bank_transaction_id        :uuid
#  bank_transaction_rule_id   :uuid
#  matched_document_id        :uuid
#  organization_id            :uuid
#
class BankTransactionRuleMatch < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :bank_transaction

  # Can be either a match for a user defined rule, or a system rule and a document
  belongs_to :rule, class_name: 'BankTransactionRule', foreign_key: 'bank_transaction_rule_id', optional: true
  belongs_to :matched_document, polymorphic: true, optional: true

  # Validations
  validates :organization, presence: true
  validates :bank_transaction, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  #
  # Shorthands
  #

  def user_defined?
    bank_transaction_rule.present?
  end

  def system_defined?
    !bank_transaction_rule.present?
  end

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
