# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transactions
#
#  id                       :uuid             not null, primary key
#  authorized_date          :date
#  authorized_datetime      :datetime
#  check_number             :string
#  credit                   :decimal(, )
#  date                     :date
#  datetime                 :datetime
#  debit                    :decimal(, )
#  iso_currency_code        :string
#  merchant_name            :string
#  name                     :string
#  payment_channel          :string
#  pending                  :boolean
#  status                   :string
#  transaction_code         :string
#  unofficial_currency_code :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :string
#  bank_account_id          :uuid
#  category_id              :string
#  transaction_id           :string
#
require 'rails_helper'

RSpec.describe BankTransaction do
  context 'has a valid factory' do
    let(:bank_transaction) { FactoryBot.build(:bank_transaction) }

    it { expect(bank_transaction).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction) { FactoryBot.build(:bank_transaction) }

    it { expect(bank_transaction).to belong_to(:bank_account) }

    it { expect(bank_transaction).to have_many(:bank_transaction_transactionables) }
    it { expect(bank_transaction).to have_many(:bank_transaction_rule_matches) }
  end

  context 'validations' do
    let(:bank_transaction) { FactoryBot.build(:bank_transaction) }

    it { expect(bank_transaction).to validate_presence_of(:bank_account) }

    it {
      expect(bank_transaction).to enumerize(:status).in(:imported, :matched, :described, :approved,
                                                        :rejected).with_default(:imported)
    }

    it {
      expect(bank_transaction).to accept_nested_attributes_for(:bank_transaction_transactionables).allow_destroy(true)
    }
  end

  context 'callbacks' do
    let(:bank_transaction) { FactoryBot.build(:bank_transaction) }

    it { expect(bank_transaction).to callback(:update_bank_transaction).before(:save) }
    it { expect(bank_transaction).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction).to callback(:can_delete?).before(:destroy) }
  end

  #
  # We need to mock the Banking API
  #

  # context 'methods' do
  #   context 'shorthands' do
  #     context '.debit? XOR .credit?'do
  #       context 'when debit > 0' do
  #         let(:bank_transaction) { FactoryBot.create(:bank_transaction, debit: 1) }

  #         it { expect(bank_transaction.debit?).to be_truthy }
  #         it { expect(bank_transaction.credit?).to be_falsey }
  #       end

  #       context 'when debit > 1' do
  #         let(:bank_transaction) { FactoryBot.create(:bank_transaction, debit: 1) }

  #         it { expect(bank_transaction.debit?).to be_truthy }
  #         it { expect(bank_transaction.credit?).to be_falsey }
  #       end
  #     end

  #     context '.account' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.account).not_to be_nil }
  #     end
  #   end

  #   context 'rules' do
  #     context '.match_rule!' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }
  #       let(:bank_transaction_rule) { FactoryBot.create(:bank_transaction_rule) }

  #       it { expect(bank_transaction.match_rule!(bank_transaction_rule)).to be_truthy }
  #     end

  #     context '.match_document!' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }
  #       let(:commercial_document) { FactoryBot.create(:commercial_document) }

  #       it { expect(bank_transaction.match_document!(commercial_document)).to be_truthy }
  #     end

  #     context '.matches?' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.matches?).to be_falsey }

  #       context 'when adding a match' do
  #         let(:commercial_document) { FactoryBot.create(:commercial_document) }
  #         before(:each) { bank_transaction.match_document!(commercial_document) }

  #         it { expect(bank_transaction.matches?).to be_truthy }
  #       end
  #     end
  #   end

  #   context 'status' do
  #     context '.reset' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.reset).to be_truthy }

  #       context 'when calling changes status' do
  #         before(:each) { bank_transaction.reset }

  #         it { expect(bank_transaction.status).to eq('imported') }
  #       end
  #     end

  #     context '.approve' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.approve).to be_truthy }

  #       context 'when calling changes status' do
  #         before(:each) { bank_transaction.approve }

  #         it { expect(bank_transaction.status).to eq('approved') }
  #       end
  #     end

  #     context '.reject' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.reject).to be_truthy }

  #       context 'when calling changes status' do
  #         before(:each) { bank_transaction.reject }

  #         it { expect(bank_transaction.status).to eq('rejected') }
  #       end
  #     end

  #     context '.review' do
  #       let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #       it { expect(bank_transaction.review).to be_truthy }

  #       context 'when calling changes status' do
  #         before(:each) { bank_transaction.review }

  #         it { expect(bank_transaction.status).to eq('described') }
  #       end
  #     end
  #   end

  #   context 'actions' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #     it { expect(bank_transaction.actions).not_to be_nil }
  #   end
  # end

  #
  # We need to mock the Banking API
  #

  # context 'permissions' do
  #   context 'update' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction) }
  #     before(:each) { bank_transaction.update(updated_at: DateTime.now.zone) }

  #     it { expect(bank_transaction.errors.size).to eq(0) }
  #   end

  #   context 'delete' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction) }
  #     before(:each) { bank_transaction.destroy }

  #     it { expect(bank_transaction.errors.size).to eq(0) }
  #   end
  # end
end
