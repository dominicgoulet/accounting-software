# frozen_string_literal: true

class CreateBusinessUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :business_units, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :parent_business_unit, type: :uuid, null: true, foreign_key: { to_table: :business_units }

      t.string :name
      t.string :description
      t.string :full_path

      t.boolean :system, default: false
      t.string :internal_code

      t.timestamps
    end
  end
end
