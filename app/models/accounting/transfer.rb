# frozen_string_literal: true

# == Schema Information
#
# Table name: transfers
#
#  id              :uuid             not null, primary key
#  amount          :decimal(, )
#  date            :date
#  note            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  from_account_id :uuid
#  organization_id :uuid
#  to_account_id   :uuid
#
class Transfer < ApplicationRecord
  extend Enumerize

  # Concerns
  include Journalable
  include BankTransactionable

  # Associations
  belongs_to :organization
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'
  has_many_attached :attached_files

  # Validations
  validates :organization, presence: true
  validates :from_account, presence: true
  validates :to_account, presence: true
  validates :date, presence: true

  # Enumerations
  enumerize :status, in: %i[new], default: :new

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
