# frozen_string_literal: true

class CreateBankTransactionRuleAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rule_accounts, id: :uuid do |t|
      t.references :bank_transaction_rule, type: :uuid, foreign_key: true,
                                           index: { name: 'index_bank_trx_rule_accounts_on_bank_trx_rule_id' }
      t.references :bank_account, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
