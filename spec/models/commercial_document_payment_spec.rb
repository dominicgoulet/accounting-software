# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_payments
#
#  id                     :uuid             not null, primary key
#  amount                 :decimal(, )
#  currency               :string
#  date                   :date
#  exchange_rate          :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :uuid
#  commercial_document_id :uuid
#  organization_id        :uuid
#
require 'rails_helper'

RSpec.describe CommercialDocumentPayment do
  context 'has a valid factory' do
    let(:commercial_document_payment) { FactoryBot.build(:commercial_document_payment) }

    it { expect(commercial_document_payment).to be_valid }
  end

  context 'associations' do
    let(:commercial_document_payment) { FactoryBot.build(:commercial_document_payment) }

    it { expect(commercial_document_payment).to belong_to(:organization) }
    it { expect(commercial_document_payment).to belong_to(:document) }
    it { expect(commercial_document_payment).to belong_to(:account) }

    it { expect(commercial_document_payment).to have_many_attached(:attached_files) }
  end

  context 'validations' do
    let(:commercial_document_payment) { FactoryBot.build(:commercial_document_payment) }

    it { expect(commercial_document_payment).to validate_presence_of(:organization) }
    it { expect(commercial_document_payment).to validate_presence_of(:document) }
    it { expect(commercial_document_payment).to validate_presence_of(:account) }
    it { expect(commercial_document_payment).to validate_presence_of(:date) }
    it { expect(commercial_document_payment).to validate_presence_of(:amount) }

    it { expect(commercial_document_payment).to enumerize(:status).in(:new).with_default(:new) }
  end

  context 'callbacks' do
    let(:commercial_document_payment) { FactoryBot.build(:commercial_document_payment) }

    it { expect(commercial_document_payment).to callback(:update_calculated_fields).after(:save) }
    it { expect(commercial_document_payment).to callback(:update_calculated_fields).after(:destroy) }
    it { expect(commercial_document_payment).to callback(:can_update?).before(:update) }
    it { expect(commercial_document_payment).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:commercial_document_payment) { FactoryBot.create(:commercial_document_payment) }
      before(:each) { commercial_document_payment.update(updated_at: DateTime.now.zone) }

      it { expect(commercial_document_payment.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:commercial_document_payment) { FactoryBot.create(:commercial_document_payment) }
      before(:each) { commercial_document_payment.destroy }

      it { expect(commercial_document_payment.errors.size).to eq(0) }
    end
  end
end
