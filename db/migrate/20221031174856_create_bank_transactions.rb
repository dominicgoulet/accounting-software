# frozen_string_literal: true

class CreateBankTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transactions, id: :uuid do |t|
      t.references :bank_account, type: :uuid, foreign_key: true

      t.string :account_id
      t.string :transaction_id
      t.string :category_id
      t.string :payment_channel
      t.string :name
      t.string :merchant_name
      t.decimal :debit
      t.decimal :credit
      t.string :iso_currency_code
      t.string :unofficial_currency_code
      t.date :date
      t.datetime :datetime
      t.date :authorized_date
      t.datetime :authorized_datetime
      t.boolean :pending
      t.string :check_number
      t.string :transaction_code

      t.string :status

      t.timestamps
    end
  end
end
