# frozen_string_literal: true

class CreateRoleMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :role_members, id: :uuid do |t|
      t.references :role, type: :uuid, foreign_key: true
      t.references :membership, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
