# frozen_string_literal: true

class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :from_account, type: :uuid, foreign_key: { to_table: :accounts }
      t.references :to_account, type: :uuid, foreign_key: { to_table: :accounts }

      t.date :date
      t.decimal :amount
      t.string :note

      t.timestamps
    end
  end
end
