# frozen_string_literal: true

class CreateBankAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.references :bank_credential, type: :uuid, foreign_key: true

      t.string :account_id

      t.decimal :available_balance
      t.decimal :current_balance
      t.decimal :limit
      t.string :iso_currency_code
      t.string :unofficial_currency_code

      t.string :mask
      t.string :name
      t.string :official_name
      t.string :account_type
      t.string :account_subtype

      t.string :status

      t.timestamps
    end
  end
end
