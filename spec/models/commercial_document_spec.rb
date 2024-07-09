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

RSpec.describe CommercialDocument do
  context 'has a valid factory' do
    let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

    it { expect(commercial_document).to be_valid }
  end

  context 'associations' do
    let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

    it { expect(commercial_document).to belong_to(:organization) }
    it { expect(commercial_document).to belong_to(:contact) }
    it { expect(commercial_document).to belong_to(:account).optional }

    it { expect(commercial_document).to have_many(:outgoing_emails) }
    it { expect(commercial_document).to have_many_attached(:attached_files) }
    it { expect(commercial_document).to have_many(:lines) }
    it { expect(commercial_document).to have_many(:taxes) }
    it { expect(commercial_document).to have_many(:payments) }
    it { expect(commercial_document).to have_many(:bank_transaction_rule_matches).through(:organization) }
    it { expect(commercial_document).to have_many(:transactions).through(:bank_transaction_rule_matches) }
  end

  context 'validations' do
    let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

    it { expect(commercial_document).to validate_presence_of(:organization) }
    it { expect(commercial_document).to validate_presence_of(:contact) }
    it { expect(commercial_document).to validate_presence_of(:date) }

    it { expect(commercial_document).not_to validate_presence_of(:due_date) }
    it { expect(commercial_document).not_to validate_presence_of(:account) }

    it {
      expect(commercial_document).to enumerize(:taxes_calculation).in(:inclusive, :exclusive).with_default(:inclusive)
    }

    it { expect(commercial_document).to accept_nested_attributes_for(:lines).allow_destroy(true) }
    it { expect(commercial_document).to accept_nested_attributes_for(:taxes).allow_destroy(true) }
  end

  context 'callbacks' do
    let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

    it { expect(commercial_document).to callback(:set_defaults).after(:initialize) }
    it { expect(commercial_document).to callback(:update_calculated_fields).before(:save) }
    it { expect(commercial_document).to callback(:can_update?).before(:update) }
    it { expect(commercial_document).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'aspects' do
      let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

      context 'expirable?' do
        it { expect(commercial_document.expirable?).to be_falsey }
      end

      context 'accountable?' do
        it { expect(commercial_document.accountable?).to be_falsey }
      end

      context 'payable?' do
        it { expect(commercial_document.payable?).to be_falsey }
      end

      context 'transactionable?' do
        it { expect(commercial_document.transactionable?).to be_falsey }
      end
    end

    context 'update_calculated_fields' do
      let(:commercial_document) { FactoryBot.build(:commercial_document, type: nil) }

      it { expect(commercial_document.update_calculated_fields).to be_truthy }
    end
  end

  context 'permissions' do
    context 'update' do
      let(:commercial_document) { FactoryBot.create(:commercial_document) }
      before(:each) { commercial_document.update(updated_at: DateTime.now.zone) }

      it { expect(commercial_document.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:commercial_document) { FactoryBot.create(:commercial_document) }
      before(:each) { commercial_document.destroy }

      it { expect(commercial_document.errors.size).to eq(0) }
    end
  end
end
