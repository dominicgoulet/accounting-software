# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_matches
#
#  id                         :uuid             not null, primary key
#  matched_document_type      :string
#  matched_rule_internal_name :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  bank_transaction_id        :uuid
#  bank_transaction_rule_id   :uuid
#  matched_document_id        :uuid
#  organization_id            :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRuleMatch do
  context 'has a valid factory' do
    let(:bank_transaction_rule_match) { FactoryBot.build(:bank_transaction_rule_match) }

    it { expect(bank_transaction_rule_match).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule_match) { FactoryBot.build(:bank_transaction_rule_match) }

    it { expect(bank_transaction_rule_match).to belong_to(:organization) }
    it { expect(bank_transaction_rule_match).to belong_to(:bank_transaction) }

    it { expect(bank_transaction_rule_match).to belong_to(:rule).optional }
    it { expect(bank_transaction_rule_match).to belong_to(:matched_document).optional }
  end

  context 'validations' do
    let(:bank_transaction_rule_match) { FactoryBot.build(:bank_transaction_rule_match) }

    it { expect(bank_transaction_rule_match).to validate_presence_of(:organization) }
    it { expect(bank_transaction_rule_match).to validate_presence_of(:bank_transaction) }
  end

  context 'callbacks' do
    let(:bank_transaction_rule_match) { FactoryBot.build(:bank_transaction_rule_match) }

    it { expect(bank_transaction_rule_match).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule_match).to callback(:can_delete?).before(:destroy) }
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
