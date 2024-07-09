# frozen_string_literal: true

class CreateBankTransactionRuleDocumentLineTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rule_document_line_taxes, id: :uuid do |t|
      t.references :bank_transaction_rule_document_line, type: :uuid, foreign_key: true,
                                                         index: { name: 'index_bank_trx_rule_doc_line_taxes_on_bank_trx_rule_doc_line_id' }
      t.references :sales_tax, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
