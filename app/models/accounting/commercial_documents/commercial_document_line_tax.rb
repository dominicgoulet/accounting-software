# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_line_taxes
#
#  id                          :uuid             not null, primary key
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  commercial_document_line_id :uuid
#  sales_tax_id                :uuid
#
class CommercialDocumentLineTax < ApplicationRecord
  # Associations
  belongs_to :line, foreign_key: 'commercial_document_line_id', class_name: 'CommercialDocumentLine', inverse_of: :taxes
  belongs_to :sales_tax

  # Validations
  validates :line, presence: true
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
