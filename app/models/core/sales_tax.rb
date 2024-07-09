# frozen_string_literal: true

# == Schema Information
#
# Table name: sales_taxes
#
#  id              :uuid             not null, primary key
#  abbreviation    :string
#  name            :string
#  number          :string
#  rate            :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#
class SalesTax < ApplicationRecord
  # Concerns
  include Accountable

  # Associations
  belongs_to :organization
  has_many :journal_entry_lines, through: :account

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validates :rate, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |sales_tax|
                  [sales_tax.organization, :sales_taxes]
                }, inserts_by: :prepend, partial: 'settings/sales_taxes/sales_tax'

  private

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless journal_entry_lines.any?

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
