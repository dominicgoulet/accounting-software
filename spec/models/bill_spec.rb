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

RSpec.describe Bill do
  context 'has a valid factory' do
    let(:bill) { FactoryBot.build(:bill) }

    it { expect(bill).to be_valid }
  end

  context 'validations' do
    let(:bill) { FactoryBot.build(:bill) }

    it { expect(bill).to validate_presence_of(:due_date) }
    it { expect(bill).not_to validate_presence_of(:account) }

    it { expect(bill).to enumerize(:status).in(:draft, :new, :late, :paid).with_default(:draft) }
  end

  context 'methods' do
    context 'aspects' do
      let(:bill) { FactoryBot.build(:bill) }

      context 'expirable?' do
        it { expect(bill.expirable?).to be_truthy }
      end

      context 'accountable?' do
        it { expect(bill.accountable?).to be_falsey }
      end

      context 'payable?' do
        it { expect(bill.payable?).to be_truthy }
      end

      context 'transactionable?' do
        it { expect(bill.transactionable?).to be_falsey }
      end
    end

    context 'actions' do
      let(:bill) { FactoryBot.create(:bill) }

      it { expect(bill.actions).not_to be_nil }
    end
  end
end
