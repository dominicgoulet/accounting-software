# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_lines
#
#  id               :uuid             not null, primary key
#  credit           :decimal(, )
#  debit            :decimal(, )
#  description      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :uuid
#  business_unit_id :uuid
#  contact_id       :uuid
#  journal_entry_id :uuid
#
class JournalEntryLine < ApplicationRecord
  # Associations
  belongs_to :journal_entry
  belongs_to :account
  belongs_to :contact, optional: true
  belongs_to :business_unit, optional: true

  # Validations
  validates :journal_entry, presence: true
  validates :account, presence: true
  validates :contact, presence: true, if: ->(obj) { ['ACCOUNTS_RECEIVABLE', 'ACCOUNTS_PAYABLE'].include?(obj.account&.internal_code)  }

  # Callbacks
  before_save :update_calculated_fields
  after_save :update_account
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  private

  def update_calculated_fields
    self.contact = nil unless ['ACCOUNTS_RECEIVABLE', 'ACCOUNTS_PAYABLE'].include?(self.account&.internal_code)
    self.debit = 0 unless debit.present?
    self.credit = 0 unless credit.present?
  end

  def update_account
    account.save
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
