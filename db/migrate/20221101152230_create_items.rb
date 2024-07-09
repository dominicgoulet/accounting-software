# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid

      t.string :name
      t.string :ugs
      t.string :cup
      t.string :status

      # Sell
      t.boolean :sell, default: false
      t.references :income_account, type: :uuid, foreign_key: { to_table: :accounts }
      t.string :sell_description
      t.decimal :sell_price

      # Buy
      t.boolean :buy, default: false
      t.references :expense_account, type: :uuid, foreign_key: { to_table: :accounts }
      t.string :buy_description
      t.decimal :buy_price

      t.timestamps
    end
  end
end
