# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
