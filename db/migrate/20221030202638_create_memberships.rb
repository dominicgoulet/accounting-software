# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :organization, type: :uuid, null: false, foreign_key: true

      t.string :level

      t.datetime :confirmed_at

      t.datetime :last_logged_in_at

      t.timestamps
    end
  end
end
