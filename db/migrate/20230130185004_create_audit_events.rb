# frozen_string_literal: true

class CreateAuditEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_events, id: :uuid do |t|
      t.references :integration, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid

      t.uuid :auditable_id, null: true
      t.string :auditable_type, null: true

      t.datetime :occured_at

      t.string :action

      t.jsonb :current_value

      t.timestamps
    end
  end
end
