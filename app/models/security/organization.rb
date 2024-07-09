# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                 :uuid             not null, primary key
#  name               :string
#  website            :string
#  setup_completed_at :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Organization < ApplicationRecord
  # Associations
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :roles, dependent: :destroy
  has_many :business_units, dependent: :destroy
  has_many :permissions, dependent: :destroy

  has_many :integrations, dependent: :destroy
  has_many :audit_events, dependent: :destroy

  has_many :contacts, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :journal_entries, dependent: :destroy
  has_many :sales_taxes, dependent: :destroy
  has_many :items, dependent: :destroy

  has_many :commercial_documents, dependent: :destroy
  has_many :payments, through: :commercial_documents
  has_many :purchase_orders, dependent: :destroy
  has_many :bills, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :estimates, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :deposits, dependent: :destroy
  has_many :transfers, dependent: :destroy

  has_many :bank_credentials, dependent: :destroy
  has_many :bank_accounts, through: :bank_credentials
  has_many :bank_transactions, through: :bank_accounts
  has_many :bank_transaction_rules, dependent: :destroy
  has_many :bank_transaction_rule_matches, dependent: :destroy

  has_many :outgoing_emails, dependent: :destroy
  has_many :recurring_events, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :website, length: { maximum: 255 }

  # Callbacks
  after_create :setup
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |organization|
                  [organization, :organizations]
                }, inserts_by: :prepend, partial: 'settings/organizations/organization'

  after_commit :send_organization_name, on: [:update]
  def send_organization_name
    broadcast_update_to [self, :session],
                        target: 'session-current-organization-name',
                        html: name
  end

  #
  # Setup management
  #

  def setup_completed!
    return false if setup_completed?

    update(
      setup_completed_at: Time.zone.now
    )
  end

  def setup_completed?
    setup_completed_at.present?
  end

  #
  # Membership management
  #

  def add_member!(user, level = :member)
    m = memberships.find_or_create_by(user:, level:)
    m.confirm!
    m
  end

  def remove_member!(user)
    m = memberships.find_by(user:, level: %i[admin member])
    return false if m.blank?

    m.destroy
  end

  def member?(user)
    memberships.find_by(user:).present?
  end

  def promote!(user)
    m = memberships.find_by(user:, level: %i[admin member])
    return false if m.blank?

    m.update(level: :admin)
  end

  def demote!(user)
    m = memberships.find_by(user:, level: %i[admin member])
    return false if m.blank?

    m.update(level: :member)
  end

  def define_owner!(user)
    memberships.find_or_create_by(user:).update(level: :owner)
  end

  private

  def setup
    # integrations
    integrations.create(
      name: 'Ninetyfour',
      system: true,
      internal_code: 'NINETYFOUR'
    )

    # contacts
    contacts.create(
      display_name: 'Ninetyfour',
      company_name: 'Ninetyfour',
      email: 'info@ninetyfour.io',
      phone_number: '15814770427',
      website: 'https://www.ninetyfour.io'
    )

    # charter of accounts
    accounts.create(
      classification: 'asset',
      reference: 1100,
      name: 'Comptes clients',
      system: true,
      internal_code: 'ACCOUNTS_RECEIVABLE'
    )

    accounts.create(
      classification: 'asset',
      reference: 1999,
      name: 'Actifs non catégorisés',
      system: true,
      internal_code: 'UNASSIGNED_ASSETS'
    )

    accounts.create(
      classification: 'liability',
      reference: 2100,
      name: 'Comptes fournisseurs',
      system: true,
      internal_code: 'ACCOUNTS_PAYABLE'
    )

    accounts.create(
      classification: 'liability',
      reference: 2999,
      name: 'Passifs non catégorisés',
      system: true,
      internal_code: 'UNASSIGNED_LIABILITIES'
    )

    accounts.create(
      classification: 'equity',
      reference: 3000,
      name: 'Bénéfices non répartis',
      system: true,
      internal_code: 'RETAINED_EARNINGS'
    )

    accounts.create(
      classification: 'equity',
      reference: 3050,
      name: 'Bénéfices de l\'année en cours',
      system: true,
      internal_code: 'CURRENT_YEAR_EARNINGS'
    )

    accounts.create(
      classification: 'equity',
      reference: 3050,
      name: 'Solde d\'ouverture',
      system: true,
      internal_code: 'OPENING_BALANCE_EQUITY'
    )

    accounts.create(
      classification: 'income',
      reference: 4999,
      name: 'Revenus non catégorisés',
      system: true,
      internal_code: 'UNASSIGNED_INCOME'
    )

    accounts.create(
      classification: 'expense',
      reference: 5999,
      name: 'Dépenses non catégorisés',
      system: true,
      internal_code: 'UNASSIGNED_EXPENSES'
    )
  end

  def can_update?
    true
  end

  def can_delete?
    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
