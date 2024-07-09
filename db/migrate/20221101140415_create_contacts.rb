# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true

      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :display_name

      t.string :phone_number
      t.string :email
      t.string :website

      t.string :currency

      t.string :status
      t.boolean :is_vendor
      t.boolean :is_customer
      t.boolean :is_employee

      t.timestamps
    end
  end
end
