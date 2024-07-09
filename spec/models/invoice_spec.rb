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

RSpec.describe Invoice do
  context 'has a valid factory' do
    let(:invoice) { FactoryBot.build(:invoice) }

    it { expect(invoice).to be_valid }
  end

  context 'validations' do
    let(:invoice) { FactoryBot.build(:invoice) }

    it { expect(invoice).to validate_presence_of(:due_date) }
    it { expect(invoice).not_to validate_presence_of(:account) }

    it { expect(invoice).to enumerize(:status).in(:draft, :new, :sent, :late, :paid).with_default(:draft) }
  end

  context 'methods' do
    context 'aspects' do
      let(:invoice) { FactoryBot.build(:invoice) }

      context 'expirable?' do
        it { expect(invoice.expirable?).to be_truthy }
      end

      context 'accountable?' do
        it { expect(invoice.accountable?).to be_falsey }
      end

      context 'payable?' do
        it { expect(invoice.payable?).to be_truthy }
      end

      context 'transactionable?' do
        it { expect(invoice.transactionable?).to be_falsey }
      end
    end

    context 'actions' do
      let(:invoice) { FactoryBot.create(:invoice) }

      it { expect(invoice.actions).not_to be_nil }
    end
  end
end
