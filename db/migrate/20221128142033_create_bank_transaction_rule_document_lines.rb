# frozen_string_literal: true

class CreateBankTransactionRuleDocumentLines < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rule_document_lines, id: :uuid do |t|
      t.references :bank_transaction_rule, type: :uuid, foreign_key: true,
                                           index: { name: 'index_bank_trx_rule_document_lines_on_bank_trx_rule_id' }

      t.decimal :percentage
      t.references :account, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
