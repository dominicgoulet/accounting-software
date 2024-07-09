# frozen_string_literal: true

class CreateIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :integrations, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid

      t.string :name
      t.string :webhook_url
      t.string :subscribed_webhooks, array: true, default: []

      # encrypted data
      t.text :secret_key_ciphertext

      # blind index
      t.string :secret_key_bidx

      # Ninetyfour specific
      t.boolean :system, default: false
      t.string :internal_code

      t.timestamps
    end

    add_index :integrations, :secret_key_bidx, unique: true
  end
end
