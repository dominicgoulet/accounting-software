# frozen_string_literal: true

class CreateCommercialDocumentTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :commercial_document_taxes, id: :uuid do |t|
      t.references :commercial_document, type: :uuid, foreign_key: true
      t.references :sales_tax, type: :uuid, foreign_key: true

      t.boolean :calculate_from_rate
      t.decimal :amount

      t.timestamps
    end
  end
end
