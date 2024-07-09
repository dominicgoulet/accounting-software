# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_documents
#
#  id                :uuid             not null, primary key
#  amount_due        :decimal(, )
#  amount_paid       :decimal(, )
#  currency          :string
#  date              :date
#  due_date          :date
#  exchange_rate     :decimal(, )
#  number            :string
#  status            :string
#  subtotal          :decimal(, )
#  taxes_amount      :decimal(, )
#  taxes_calculation :string
#  total             :decimal(, )
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :uuid
#  contact_id        :uuid
#  organization_id   :uuid
#
require 'rails_helper'

RSpec.describe Expense do
  context 'has a valid factory' do
    let(:expense) { FactoryBot.build(:expense) }

    it { expect(expense).to be_valid }
  end

  context 'validations' do
    let(:expense) { FactoryBot.build(:expense) }

    it { expect(expense).not_to validate_presence_of(:due_date) }
    it { expect(expense).to validate_presence_of(:account) }

    it { expect(expense).to enumerize(:status).in(:draft, :incomplete, :paid).with_default(:paid) }
  end

  context 'methods' do
    context 'aspects' do
      let(:expense) { FactoryBot.build(:expense) }

      context 'expirable?' do
        it { expect(expense.expirable?).to be_falsey }
      end

      context 'accountable?' do
        it { expect(expense.accountable?).to be_truthy }
      end

      context 'payable?' do
        it { expect(expense.payable?).to be_falsey }
      end

      context 'transactionable?' do
        it { expect(expense.transactionable?).to be_truthy }
      end
    end

    context 'actions' do
      let(:expense) { FactoryBot.create(:expense) }

      it { expect(expense.actions).not_to be_nil }
    end
  end
end
