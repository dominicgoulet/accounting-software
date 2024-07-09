# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rules
#
#  id                    :uuid             not null, primary key
#  action                :string
#  auto_apply            :boolean
#  document_type         :string
#  match_all_conditions  :boolean
#  match_debit_or_credit :string
#  name                  :string
#  priority              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_id            :uuid
#  organization_id       :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRule do
  context 'has a valid factory' do
    let(:bank_transaction_rule) { FactoryBot.build(:bank_transaction_rule) }

    it { expect(bank_transaction_rule).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule) { FactoryBot.build(:bank_transaction_rule) }

    it { expect(bank_transaction_rule).to belong_to(:organization) }
    it { expect(bank_transaction_rule).to belong_to(:contact).optional }

    it { expect(bank_transaction_rule).to have_many(:bank_transaction_rule_accounts) }
    it { expect(bank_transaction_rule).to have_many(:bank_transaction_rule_conditions) }
    it { expect(bank_transaction_rule).to have_many(:bank_transaction_rule_document_lines) }
    it { expect(bank_transaction_rule).to have_many(:bank_transaction_rule_matches) }
    it { expect(bank_transaction_rule).to have_many(:bank_accounts).through(:bank_transaction_rule_accounts) }
  end

  context 'validations' do
    let(:bank_transaction_rule) { FactoryBot.build(:bank_transaction_rule) }

    it { expect(bank_transaction_rule).to validate_presence_of(:organization) }
    it { expect(bank_transaction_rule).to validate_presence_of(:name) }

    it {
      expect(bank_transaction_rule).to accept_nested_attributes_for(:bank_transaction_rule_accounts).allow_destroy(true)
    }
    it {
      expect(bank_transaction_rule).to accept_nested_attributes_for(:bank_transaction_rule_conditions).allow_destroy(true)
    }
    it {
      expect(bank_transaction_rule).to accept_nested_attributes_for(:bank_transaction_rule_document_lines).allow_destroy(true)
    }
  end

  context 'callbacks' do
    let(:bank_transaction_rule) { FactoryBot.build(:bank_transaction_rule) }

    it { expect(bank_transaction_rule).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:bank_transaction_rule) { FactoryBot.create(:bank_transaction_rule) }
      before(:each) { bank_transaction_rule.update(updated_at: DateTime.now.zone) }

      it { expect(bank_transaction_rule.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:bank_transaction_rule) { FactoryBot.create(:bank_transaction_rule) }
      before(:each) { bank_transaction_rule.destroy }

      it { expect(bank_transaction_rule.errors.size).to eq(0) }
    end
  end
end
