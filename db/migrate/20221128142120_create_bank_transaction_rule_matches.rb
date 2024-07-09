# frozen_string_literal: true

class CreateBankTransactionRuleMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transaction_rule_matches, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :bank_transaction, type: :uuid, foreign_key: true

      # Reference to a user defined rule
      t.references :bank_transaction_rule, type: :uuid, foreign_key: true

      # Or reference to a hard coded rule
      t.string :matched_rule_internal_name
      t.uuid :matched_document_id, null: true
      t.string :matched_document_type, null: true

      t.timestamps
    end
  end
end
