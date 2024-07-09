# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.uuid :addressable_id, null: true
      t.string :addressable_type, null: true

      t.string :line1
      t.string :line2
      t.string :city
      t.string :state_or_province
      t.string :country
      t.string :zip_or_postal_code

      t.timestamps
    end
  end
end
