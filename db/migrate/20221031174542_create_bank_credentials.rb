# frozen_string_literal: true

class CreateBankCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_credentials, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true

      t.string :public_token
      t.string :access_token

      t.string :latest_cursor

      t.string :institution_id
      t.string :name
      t.string :url
      t.string :primary_color
      t.text :logo

      t.datetime :last_sync_at
      t.string :status
      t.string :error_type
      t.string :error_code

      t.timestamps
    end
  end
end
