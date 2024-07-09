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

RSpec.describe Estimate do
  context 'has a valid factory' do
    let(:estimate) { FactoryBot.build(:estimate) }

    it { expect(estimate).to be_valid }
  end

  context 'validations' do
    let(:estimate) { FactoryBot.build(:estimate) }

    it { expect(estimate).to validate_presence_of(:due_date) }
    it { expect(estimate).not_to validate_presence_of(:account) }

    it { expect(estimate).to enumerize(:status).in(:draft, :new, :pending, :won, :lost).with_default(:draft) }
  end

  context 'methods' do
    context 'aspects' do
      let(:estimate) { FactoryBot.build(:estimate) }

      context 'expirable?' do
        it { expect(estimate.expirable?).to be_truthy }
      end

      context 'accountable?' do
        it { expect(estimate.accountable?).to be_falsey }
      end

      context 'payable?' do
        it { expect(estimate.payable?).to be_falsey }
      end

      context 'transactionable?' do
        it { expect(estimate.transactionable?).to be_falsey }
      end
    end

    context 'actions' do
      let(:estimate) { FactoryBot.create(:estimate) }

      it { expect(estimate.actions).not_to be_nil }
    end
  end
end
