# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_document_lines
#
#  id                       :uuid             not null, primary key
#  percentage               :decimal(, )
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :uuid
#  bank_transaction_rule_id :uuid
#
class BankTransactionRuleDocumentLine < ApplicationRecord
  # Associations
  belongs_to :bank_transaction_rule
  belongs_to :account
  has_many :bank_transaction_rule_document_line_taxes, dependent: :destroy

  def taxes
    bank_transaction_rule_document_line_taxes
  end

  # Validations
  validates :bank_transaction_rule, presence: true
  validates :account, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :bank_transaction_rule_document_line_taxes, allow_destroy: true

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
