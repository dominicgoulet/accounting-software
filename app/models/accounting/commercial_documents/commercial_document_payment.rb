# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_payments
#
#  id                     :uuid             not null, primary key
#  amount                 :decimal(, )
#  currency               :string
#  date                   :date
#  exchange_rate          :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :uuid
#  commercial_document_id :uuid
#  organization_id        :uuid
#
class CommercialDocumentPayment < ApplicationRecord
  extend Enumerize

  # Concerns
  include Journalable
  include BankTransactionable

  # Associations
  belongs_to :organization
  belongs_to :document, foreign_key: 'commercial_document_id', class_name: 'CommercialDocument'
  belongs_to :account
  has_many_attached :attached_files

  # Validations
  validates :organization, presence: true
  validates :document, presence: true
  validates :account, presence: true
  validates :date, presence: true
  validates :amount, presence: true

  # Enumerations
  enumerize :status, in: %i[new], default: :new

  # Callbacks
  after_save :update_calculated_fields
  after_destroy :update_calculated_fields
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |commercial_document_payment|
                  [commercial_document_payment.organization, commercial_document_payment.document, :commercial_document_payments]
                }, inserts_by: :prepend

  private

  def update_calculated_fields
    return if destroyed_by_association.present?

    document.update_calculated_fields
    document.save
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
