# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_credentials
#
#  id              :uuid             not null, primary key
#  access_token    :string
#  error_code      :string
#  error_type      :string
#  last_sync_at    :datetime
#  latest_cursor   :string
#  logo            :text
#  name            :string
#  primary_color   :string
#  public_token    :string
#  status          :string
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  institution_id  :string
#  organization_id :uuid
#
class BankCredential < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  has_many :bank_accounts, dependent: :destroy

  # Validations
  validates :organization, presence: true
  validates :access_token, presence: true

  # Enumerations
  enumerize :status, in: %i[ok error], default: :ok

  # Callbacks
  before_create :fetch_institution_info
  after_create :fetch_accounts_info
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |bank_credential|
                  [bank_credential.organization, :bank_credentials]
                }, inserts_by: :prepend, partial: 'settings/bank_credentials/bank_credential'

  private

  def fetch_institution_info
    institution = Banking.get_institution(access_token)

    self.institution_id = institution.institution_id
    self.name = institution.name
    self.url = institution.url
    self.primary_color = institution.primary_color
    self.logo = institution.logo
  end

  def fetch_accounts_info
    accounts, get_accounts_success = Banking.get_accounts(self)

    return unless get_accounts_success

    accounts.each do |account|
      bank_accounts
        .find_or_create_by(account_id: account.account_id)
        .update(
          available_balance: (account.balances.available || 0),
          current_balance: (account.balances.current || 0),
          limit: (account.balances.limit || 0),
          iso_currency_code: account.balances.iso_currency_code,
          unofficial_currency_code: account.balances.unofficial_currency_code,
          mask: account.mask,
          name: account.name,
          official_name: account.official_name,
          account_type: account.type,
          account_subtype: account.subtype
        )
    end

    update(last_sync_at: Time.zone.now)
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
