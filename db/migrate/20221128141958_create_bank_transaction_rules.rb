# frozen_string_literal: true

class CreateBankTransactionRules < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rules, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true

      t.integer :priority
      t.string :name

      t.string :match_debit_or_credit
      t.boolean :match_all_conditions

      t.string :action
      t.string :document_type

      t.references :contact, type: :uuid, foreign_key: true

      t.boolean :auto_apply

      t.timestamps
    end
  end
end
