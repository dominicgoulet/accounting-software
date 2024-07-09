# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_lines
#
#  id                     :uuid             not null, primary key
#  description            :string
#  order                  :integer
#  quantity               :decimal(, )
#  subtotal               :decimal(, )
#  unit_price             :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :uuid
#  commercial_document_id :uuid
#  item_id                :uuid
#
class CommercialDocumentLine < ApplicationRecord
  # Associations
  belongs_to :document, foreign_key: 'commercial_document_id', class_name: 'CommercialDocument', inverse_of: :lines
  belongs_to :account
  belongs_to :item, optional: true
  has_many :taxes, foreign_key: 'commercial_document_line_id', class_name: 'CommercialDocumentLineTax', inverse_of: :line

  # Validations
  validates :document, presence: true
  validates :account, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :taxes, allow_destroy: true, reject_if: lambda { |c| c[:id].blank? && c[:sales_tax_id].blank? }

  def update_calculated_fields
    self.quantity = 0 unless quantity.present?
    self.unit_price = 0 unless unit_price.present?
    self.subtotal = quantity * actual_unit_price

    true
  end

  def item_name
    return item.name if item.present?

    account.display_name
  end

  def actual_unit_price
    return_value = unit_price

    if document.taxes_calculation.inclusive?
      sales_tax_total_rate = taxes.sum { |elt| elt.sales_tax.rate }
      sales_tax_total_rate = 1 + (sales_tax_total_rate / 100.0)

      amount_without_taxes = (unit_price / sales_tax_total_rate).round(2)

      return_value = amount_without_taxes
    end

    return_value
  end

  def expected_total
    return_value = quantity * unit_price

    if document.taxes_calculation.exclusive?
      # add taxes here
    end

    return_value
  end

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
