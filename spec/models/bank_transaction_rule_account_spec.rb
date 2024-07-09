# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_accounts
#
#  id                       :uuid             not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank_account_id          :uuid
#  bank_transaction_rule_id :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRuleAccount do
  context 'has a valid factory' do
    let(:bank_transaction_rule_account) { FactoryBot.build(:bank_transaction_rule_account) }

    it { expect(bank_transaction_rule_account).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule_account) { FactoryBot.build(:bank_transaction_rule_account) }

    it { expect(bank_transaction_rule_account).to belong_to(:bank_transaction_rule) }
    it { expect(bank_transaction_rule_account).to belong_to(:bank_account) }
  end

  context 'validations' do
    let(:bank_transaction_rule_account) { FactoryBot.build(:bank_transaction_rule_account) }

    it { expect(bank_transaction_rule_account).to validate_presence_of(:bank_transaction_rule) }
    it { expect(bank_transaction_rule_account).to validate_presence_of(:bank_account) }
  end

  context 'callbacks' do
    let(:bank_transaction_rule_account) { FactoryBot.build(:bank_transaction_rule_account) }

    it { expect(bank_transaction_rule_account).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule_account).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  #
  # We need to mock the Banking API
  #

  # context 'permissions' do
  #   context 'update' do
  #     let(:bank_credential) { FactoryBot.build(:bank_credential) }
  #     before(:each) { bank_credential.update(updated_at: DateTime.now.zone) }

  #     it { expect(bank_credential.errors.size).to eq(0) }
  #   end

  #   context 'delete' do
  #     let(:bank_credential) { FactoryBot.build(:bank_credential) }
  #     before(:each) { bank_credential.destroy }

  #     it { expect(bank_credential.errors.size).to eq(0) }
  #   end
  # end
end
