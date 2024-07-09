# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_transactionables
#
#  id                   :uuid             not null, primary key
#  amount               :decimal(, )
#  transactionable_type :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  bank_transaction_id  :uuid
#  transactionable_id   :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionTransactionable do
  context 'has a valid factory' do
    let(:bank_transaction_transactionable) { FactoryBot.build(:bank_transaction_transactionable) }

    it { expect(bank_transaction_transactionable).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_transactionable) { FactoryBot.build(:bank_transaction_transactionable) }

    it { expect(bank_transaction_transactionable).to belong_to(:bank_transaction) }
    it { expect(bank_transaction_transactionable).to belong_to(:transactionable) }
  end

  context 'validations' do
    let(:bank_transaction_transactionable) { FactoryBot.build(:bank_transaction_transactionable) }

    it { expect(bank_transaction_transactionable).to validate_presence_of(:bank_transaction) }
    it { expect(bank_transaction_transactionable).to validate_presence_of(:transactionable) }
    it { expect(bank_transaction_transactionable).to validate_associated(:transactionable) }
  end

  context 'callbacks' do
    let(:bank_transaction_transactionable) { FactoryBot.build(:bank_transaction_transactionable) }

    it { expect(bank_transaction_transactionable).to callback(:update_bank_transaction).after(:save) }
    it { expect(bank_transaction_transactionable).to callback(:update_bank_transaction).after(:destroy) }
    it { expect(bank_transaction_transactionable).to callback(:set_amount).before(:save) }
    it { expect(bank_transaction_transactionable).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_transactionable).to callback(:can_delete?).before(:destroy) }
  end

  #
  # We need to mock the Banking API
  #

  # context 'methods' do
  #   context '.update_total' do
  #     let(:bank_transaction_transactionable) { FactoryBot.create(:bank_transaction_transactionable) }

  #     it { expect(bank_transaction_transactionable.update_total).to be_truthy }
  #   end
  # end

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
