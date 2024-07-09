# frozen_string_literal: true

class CreateAccountTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :account_taxes, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.references :sales_tax, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
