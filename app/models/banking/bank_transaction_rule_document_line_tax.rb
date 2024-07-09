# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_document_line_taxes
#
#  id                                     :uuid             not null, primary key
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  bank_transaction_rule_document_line_id :uuid
#  sales_tax_id                           :uuid
#
class BankTransactionRuleDocumentLineTax < ApplicationRecord
  # Associations
  belongs_to :bank_transaction_rule_document_line
  belongs_to :sales_tax

  # Validations
  validates :bank_transaction_rule_document_line, presence: true
  validates :sales_tax, presence: true

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
