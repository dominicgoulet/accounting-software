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

RSpec.describe PurchaseOrder do
  context 'has a valid factory' do
    let(:purchase_order) { FactoryBot.build(:purchase_order) }

    it { expect(purchase_order).to be_valid }
  end

  context 'validations' do
    let(:purchase_order) { FactoryBot.build(:purchase_order) }

    it { expect(purchase_order).to validate_presence_of(:due_date) }
    it { expect(purchase_order).not_to validate_presence_of(:account) }

    it {
      expect(purchase_order).to enumerize(:status).in(:draft, :new, :pending, :accepted,
                                                      :completed).with_default(:draft)
    }
  end

  context 'methods' do
    context 'aspects' do
      let(:purchase_order) { FactoryBot.build(:purchase_order) }

      context 'expirable?' do
        it { expect(purchase_order.expirable?).to be_truthy }
      end

      context 'accountable?' do
        it { expect(purchase_order.accountable?).to be_falsey }
      end

      context 'payable?' do
        it { expect(purchase_order.payable?).to be_falsey }
      end

      context 'transactionable?' do
        it { expect(purchase_order.transactionable?).to be_falsey }
      end
    end

    context 'actions' do
      let(:purchase_order) { FactoryBot.create(:purchase_order) }

      it { expect(purchase_order.actions).not_to be_nil }
    end
  end
end
