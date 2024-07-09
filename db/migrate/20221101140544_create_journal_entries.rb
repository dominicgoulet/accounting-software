# frozen_string_literal: true

class CreateJournalEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :journal_entries, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :integration, type: :uuid, foreign_key: true

      t.uuid :journalable_id, null: true
      t.string :journalable_type, null: true

      t.string :integration_journalable_type
      t.string :integration_journalable_id

      t.string :narration
      t.date :date
      t.string :currency
      t.decimal :exchange_rate

      # calculated fields
      t.decimal :total_credit
      t.decimal :total_debit

      t.timestamps
    end
  end
end
