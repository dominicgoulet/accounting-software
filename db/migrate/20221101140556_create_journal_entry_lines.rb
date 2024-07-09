# frozen_string_literal: true

class CreateJournalEntryLines < ActiveRecord::Migration[7.0]
  def change
    create_table :journal_entry_lines, id: :uuid do |t|
      t.references :journal_entry, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
      t.references :contact, type: :uuid, foreign_key: true
      t.references :business_unit, type: :uuid, foreign_key: true

      t.decimal :credit
      t.decimal :debit

      t.string :description

      t.timestamps
    end
  end
end
