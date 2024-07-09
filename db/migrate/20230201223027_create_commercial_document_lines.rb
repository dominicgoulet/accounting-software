# frozen_string_literal: true

class CreateCommercialDocumentLines < ActiveRecord::Migration[7.0]
  def change
    create_table :commercial_document_lines, id: :uuid do |t|
      t.references :commercial_document, type: :uuid, foreign_key: true
      t.references :item, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true

      t.integer :order
      t.string :description
      t.decimal :quantity
      t.decimal :unit_price

      # calculated fields
      t.decimal :subtotal

      t.timestamps
    end
  end
end
