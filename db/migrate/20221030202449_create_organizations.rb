# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :website

      t.datetime :setup_completed_at

      t.timestamps
    end
  end
end
