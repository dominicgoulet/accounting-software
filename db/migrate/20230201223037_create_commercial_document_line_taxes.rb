# frozen_string_literal: true

class CreateCommercialDocumentLineTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :commercial_document_line_taxes, id: :uuid do |t|
      t.references :commercial_document_line, type: :uuid, foreign_key: true,
                                              index: { name: 'idx_commercial_doc_line_taxes_on_commercial_doc_line_id' }
      t.references :sales_tax, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
