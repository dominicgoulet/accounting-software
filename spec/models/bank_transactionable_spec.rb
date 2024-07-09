# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankTransactionable do
  context 'has a valid factory' do
    let(:bank_transactionable) { FactoryBot.build(:deposit) }

    it { expect(bank_transactionable).to be_valid }
  end

  context 'associations' do
    let(:bank_transactionable) { FactoryBot.build(:deposit) }

    it { expect(bank_transactionable).to have_many(:bank_transaction_transactionables) }
    it { expect(bank_transactionable).to have_many(:bank_transactions).through(:bank_transaction_transactionables) }
  end

  context 'callbacks' do
    let(:bank_transactionable) { FactoryBot.build(:deposit) }

    it { expect(bank_transactionable).to callback(:update_bank_transaction_transactionables).after(:save) }
  end
end
