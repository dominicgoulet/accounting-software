# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id                       :uuid             not null, primary key
#  account_subtype          :string
#  account_type             :string
#  available_balance        :decimal(, )
#  current_balance          :decimal(, )
#  iso_currency_code        :string
#  limit                    :decimal(, )
#  mask                     :string
#  name                     :string
#  official_name            :string
#  status                   :string
#  unofficial_currency_code :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :string
#  bank_credential_id       :uuid
#
class BankAccount < ApplicationRecord
  extend Enumerize

  # Concerns
  include Accountable

  # Associations
  belongs_to :bank_credential
  has_one :organization, through: :bank_credential
  has_many :bank_transactions

  # Validations
  validates :bank_credential, presence: true

  # Enumerations
  enumerize :status, in: %i[up_to_date updating], default: :up_to_date

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to ->(bank_account) { [bank_account.organization, :bank_accounts] }, inserts_by: :prepend

  #
  # Shorthands
  #

  def icon
    case account_type
    when 'depository' then 'outline/currency-dollar'
    when 'credit' then 'outline/credit-card'
    when 'loan' then 'outline/banknotes'
    else 'trash'
    end
  end

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
