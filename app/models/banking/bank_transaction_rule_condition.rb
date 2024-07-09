# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_conditions
#
#  id                       :uuid             not null, primary key
#  condition                :string
#  field                    :string
#  value                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank_transaction_rule_id :uuid
#
class BankTransactionRuleCondition < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :bank_transaction_rule

  # Validations
  validates :bank_transaction_rule, presence: true

  # Enumerations
  enumerize :field, in: %i[description amount], default: :amount
  enumerize :condition, in: %i[contains does_not_contains is lower_than greater_than], default: :is # should be called operator

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
