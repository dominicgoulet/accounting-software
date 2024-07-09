# frozen_string_literal: true

class CreateOutgoingEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoing_emails, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true

      t.string :recipients, array: true, default: []
      t.string :title
      t.string :subject
      t.text :body

      t.uuid :related_object_id, null: true
      t.string :related_object_type, null: true

      t.timestamps
    end
  end
end
