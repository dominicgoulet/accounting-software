# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :role, type: :uuid, foreign_key: true
      t.references :business_unit, type: :uuid, foreign_key: true

      t.string :level

      t.timestamps
    end
  end
end
