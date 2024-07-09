# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :parent_account, type: :uuid, foreign_key: { to_table: :accounts }

      t.string :classification
      t.string :status
      t.integer :reference
      t.string :name
      t.string :description
      t.string :currency
      t.decimal :starting_balance

      # Calculated fields
      t.decimal :current_balance
      t.decimal :total_credit
      t.decimal :total_debit
      t.string :full_path
      t.string :account_type
      t.string :display_name

      # Ninetyfour specific
      t.boolean :system, default: false
      t.string :internal_code
      t.boolean :generated, default: false
      t.uuid :accountable_id, null: true
      t.string :accountable_type, null: true

      t.timestamps
    end
  end
end
