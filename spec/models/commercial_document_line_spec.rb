# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_document_lines
#
#  id                     :uuid             not null, primary key
#  description            :string
#  order                  :integer
#  quantity               :decimal(, )
#  subtotal               :decimal(, )
#  unit_price             :decimal(, )
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :uuid
#  commercial_document_id :uuid
#  item_id                :uuid
#
require 'rails_helper'

RSpec.describe CommercialDocumentLine do
  context 'has a valid factory' do
    let(:commercial_document_line) { FactoryBot.build(:commercial_document_line) }

    it { expect(commercial_document_line).to be_valid }
  end

  context 'associations' do
    let(:commercial_document_line) { FactoryBot.build(:commercial_document_line) }

    it { expect(commercial_document_line).to belong_to(:document) }
    it { expect(commercial_document_line).to belong_to(:account) }
    it { expect(commercial_document_line).to belong_to(:item).optional }

    it { expect(commercial_document_line).to have_many(:taxes) }
  end

  context 'validations' do
    let(:commercial_document_line) { FactoryBot.build(:commercial_document_line) }

    it { expect(commercial_document_line).to validate_presence_of(:document) }
    it { expect(commercial_document_line).to validate_presence_of(:account) }

    it { expect(commercial_document_line).to accept_nested_attributes_for(:taxes).allow_destroy(true) }
  end

  context 'callbacks' do
    let(:commercial_document_line) { FactoryBot.build(:commercial_document_line) }

    it { expect(commercial_document_line).to callback(:can_update?).before(:update) }
    it { expect(commercial_document_line).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context '.update_calculated_fields' do
      let(:commercial_document_line) { FactoryBot.build(:commercial_document_line) }

      it { expect(commercial_document_line.update_calculated_fields).to be_truthy }
    end

    context '.item_name' do
      context 'with only an account' do
        let(:account) { FactoryBot.build(:account, display_name: 'Lightsaber Parts') }
        let(:commercial_document_line) { FactoryBot.build(:commercial_document_line, account:) }

        it { expect(commercial_document_line.item_name).to eq('Lightsaber Parts') }
      end

      context 'with account and item' do
        let(:account) { FactoryBot.build(:account, name: 'Lightsaber Parts') }
        let(:item) { FactoryBot.build(:item, name: 'Lightsaber Hilt') }
        let(:commercial_document_line) { FactoryBot.build(:commercial_document_line, account:, item:) }

        it { expect(commercial_document_line.item_name).to eq('Lightsaber Hilt') }
      end
    end

    context '.actual_unit_price' do
      let(:commercial_document_line) { FactoryBot.build(:commercial_document_line, quantity: 1, unit_price: 2) }

      it { expect(commercial_document_line.actual_unit_price).to eq(2) }
    end

    context '.expected_total' do
      let(:commercial_document_line) { FactoryBot.build(:commercial_document_line, quantity: 1, unit_price: 2) }

      it { expect(commercial_document_line.expected_total).to eq(2) }
    end
  end

  context 'permissions' do
    context 'update' do
      let(:commercial_document_line) { FactoryBot.create(:commercial_document_line) }
      before(:each) { commercial_document_line.update(updated_at: DateTime.now.zone) }

      it { expect(commercial_document_line.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:commercial_document_line) { FactoryBot.create(:commercial_document_line) }
      before(:each) { commercial_document_line.destroy }

      it { expect(commercial_document_line.errors.size).to eq(0) }
    end
  end
end
