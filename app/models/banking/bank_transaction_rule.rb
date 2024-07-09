# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rules
#
#  id                    :uuid             not null, primary key
#  action                :string
#  auto_apply            :boolean
#  document_type         :string
#  match_all_conditions  :boolean
#  match_debit_or_credit :string
#  name                  :string
#  priority              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_id            :uuid
#  organization_id       :uuid
#
class BankTransactionRule < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :contact, optional: true

  has_many :bank_transaction_rule_accounts, dependent: :destroy
  has_many :bank_transaction_rule_conditions, dependent: :destroy
  has_many :bank_transaction_rule_document_lines, dependent: :destroy
  has_many :bank_transaction_rule_matches, dependent: :destroy
  has_many :bank_accounts, through: :bank_transaction_rule_accounts

  # Validations
  validates :organization, presence: true
  validates :name, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :bank_transaction_rule_accounts, allow_destroy: true, reject_if: lambda { |c|
                                                                                                   c[:bank_account_id].blank?
                                                                                                 }
  accepts_nested_attributes_for :bank_transaction_rule_conditions, allow_destroy: true, reject_if: lambda { |c|
                                                                                                     c[:value].blank?
                                                                                                   }
  accepts_nested_attributes_for :bank_transaction_rule_document_lines, allow_destroy: true, reject_if: lambda { |c|
                                                                                                         c[:account_id].blank?
                                                                                                       }

  # Hotwired
  broadcasts_to lambda { |bank_transaction_rule|
                  [bank_transaction_rule.organization, :bank_transaction_rules]
                }, inserts_by: :prepend

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
