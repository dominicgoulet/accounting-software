# frozen_string_literal: true

class CreateRecurringEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :recurring_events, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true

      t.uuid :recurrable_id, null: true
      t.string :recurrable_type, null: true

      t.string :frequency
      t.string :end_repeat
      t.date :repeat_until
      t.integer :repeat_count
      t.integer :interval

      t.integer :day_of_week, array: true, default: []
      t.integer :day_of_month, array: true, default: []
      t.integer :day_of_year, array: true, default: []
      t.integer :month_of_year, array: true, default: []

      t.timestamps
    end
  end
end
