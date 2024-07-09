# frozen_string_literal: true

# == Schema Information
#
# Table name: account_taxes
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid
#  sales_tax_id :uuid
#
class AccountTax < ApplicationRecord
  # Associations
  belongs_to :account
  belongs_to :sales_tax

  # Validations
  validates :account, presence: true
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
