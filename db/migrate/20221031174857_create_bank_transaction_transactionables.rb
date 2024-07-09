# frozen_string_literal: true

class CreateBankTransactionTransactionables < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_transactionables, id: :uuid do |t|
      t.references :bank_transaction, type: :uuid, foreign_key: true

      t.uuid :transactionable_id, null: true
      t.string :transactionable_type, null: true

      t.decimal :amount

      t.timestamps
    end
  end
end
