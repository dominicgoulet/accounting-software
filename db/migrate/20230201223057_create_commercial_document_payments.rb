# frozen_string_literal: true

class CreateCommercialDocumentPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :commercial_document_payments, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :commercial_document, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true

      t.date :date
      t.decimal :amount

      t.string :currency
      t.decimal :exchange_rate

      t.timestamps
    end
  end
end
