# frozen_string_literal: true

class CreateBankTransactionRuleConditions < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rule_conditions, id: :uuid do |t|
      t.references :bank_transaction_rule, type: :uuid, foreign_key: true,
                                           index: { name: 'index_bank_trx_rule_conditions_on_bank_trx_rule_id' }

      t.string :field
      t.string :condition
      t.string :value

      t.timestamps
    end
  end
end
