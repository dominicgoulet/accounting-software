# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_taxes
#
#  id                     :uuid             not null, primary key
#  amount                 :decimal(, )
#  calculate_from_rate    :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  commercial_document_id :uuid
#  sales_tax_id           :uuid
#
class CommercialDocumentTax < ApplicationRecord
  # Associations
  belongs_to :document, foreign_key: 'commercial_document_id', class_name: 'CommercialDocument', inverse_of: :taxes
  belongs_to :sales_tax

  # Validations
  validates :document, presence: true
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
