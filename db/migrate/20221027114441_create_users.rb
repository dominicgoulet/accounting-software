# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :password_digest

      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.integer :sign_in_count, default: 0, null: false

      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.string :first_name
      t.string :last_name

      t.datetime :setup_completed_at

      t.timestamps
    end
  end
end
