# frozen_string_literal: true

class CreateCommercialDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :commercial_documents, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :contact, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true

      t.string :type # STI

      t.string :number
      t.date :date
      t.date :due_date
      t.string :status
      t.string :taxes_calculation

      t.string :currency
      t.decimal :exchange_rate

      # calculated fields
      t.decimal :subtotal
      t.decimal :taxes_amount
      t.decimal :total
      t.decimal :amount_paid
      t.decimal :amount_due

      t.timestamps
    end
  end
end
