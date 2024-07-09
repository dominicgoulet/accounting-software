# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id                       :uuid             not null, primary key
#  account_subtype          :string
#  account_type             :string
#  available_balance        :decimal(, )
#  current_balance          :decimal(, )
#  iso_currency_code        :string
#  limit                    :decimal(, )
#  mask                     :string
#  name                     :string
#  official_name            :string
#  status                   :string
#  unofficial_currency_code :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :string
#  bank_credential_id       :uuid
#
require 'rails_helper'

RSpec.describe BankAccount do
  context 'has a valid factory' do
    let(:bank_account) { FactoryBot.build(:bank_account) }

    it { expect(bank_account).to be_valid }
  end

  context 'associations' do
    let(:bank_account) { FactoryBot.build(:bank_account) }

    it { expect(bank_account).to belong_to(:bank_credential) }

    it { expect(bank_account).to have_one(:organization).through(:bank_credential) }
    it { expect(bank_account).to have_many(:bank_transactions) }
  end

  context 'validations' do
    let(:bank_account) { FactoryBot.build(:bank_account) }

    it { expect(bank_account).to validate_presence_of(:bank_credential) }

    it { expect(bank_account).to enumerize(:status).in(:up_to_date, :updating).with_default(:up_to_date) }
  end

  context 'callbacks' do
    let(:bank_account) { FactoryBot.build(:bank_account) }

    it { expect(bank_account).to callback(:can_update?).before(:update) }
    it { expect(bank_account).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.icon' do
        context 'when account_type = depository' do
          let(:bank_account) { FactoryBot.build(:bank_account, account_type: 'depository') }

          it { expect(bank_account.icon).to eq('outline/currency-dollar') }
        end

        context 'when account_type = credit' do
          let(:bank_account) { FactoryBot.build(:bank_account, account_type: 'credit') }

          it { expect(bank_account.icon).to eq('outline/credit-card') }
        end

        context 'when account_type = loan' do
          let(:bank_account) { FactoryBot.build(:bank_account, account_type: 'loan') }

          it { expect(bank_account.icon).to eq('outline/banknotes') }
        end

        context 'when account_type = anything else' do
          let(:bank_account) { FactoryBot.build(:bank_account, account_type: 'anything else') }

          it { expect(bank_account.icon).to eq('trash') }
        end
      end
    end
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
