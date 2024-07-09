# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id              :uuid             not null, primary key
#  company_name    :string
#  currency        :string
#  display_name    :string
#  email           :string
#  first_name      :string
#  is_customer     :boolean
#  is_employee     :boolean
#  is_vendor       :boolean
#  last_name       :string
#  phone_number    :string
#  status          :string
#  website         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
class Contact < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  has_many :estimates
  has_many :invoices
  has_many :deposits
  has_many :purchase_orders
  has_many :bills
  has_many :expenses

  # Scopes
  default_scope { order(Arel.sql('LOWER(UNACCENT(display_name)) ASC')) }

  # Validations
  validates :organization, presence: true
  validates :display_name, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }

  # Enumerations
  enumerize :status, in: %i[active archived], default: :active

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to ->(contact) { [contact.organization, :contacts] }, inserts_by: :prepend

  after_commit :send_contact_display_name, on: [:update]
  def send_contact_display_name
    broadcast_update_to [organization, :contacts],
                        target: "contact_#{id}_display_name",
                        html: display_name
  end

  #
  # Will be replaced by Addressable and a real address
  #

  def address
    '2168 rue du Rail, Lévis, QC, G6X 1Y3'
  end

  #
  # Shorthands
  #

  def avatar_url
    "//www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email || '')}?d=retro&s=128"
  end

  def classification; end

  private

  def has_documents
    (estimates.size + invoices.size + deposits.size + purchase_orders.size + bills.size + expenses.size).positive?
  end

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless has_documents

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
