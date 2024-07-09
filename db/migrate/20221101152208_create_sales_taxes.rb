# frozen_string_literal: true

class CreateSalesTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :sales_taxes, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid

      t.string :name
      t.string :abbreviation
      t.string :number
      t.decimal :rate

      t.timestamps
    end
  end
end
