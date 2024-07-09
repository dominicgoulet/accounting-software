# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_document_lines
#
#  id                       :uuid             not null, primary key
#  percentage               :decimal(, )
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  account_id               :uuid
#  bank_transaction_rule_id :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRuleDocumentLine do
  context 'has a valid factory' do
    let(:bank_transaction_rule_document_line) { FactoryBot.build(:bank_transaction_rule_document_line) }

    it { expect(bank_transaction_rule_document_line).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule_document_line) { FactoryBot.build(:bank_transaction_rule_document_line) }

    it { expect(bank_transaction_rule_document_line).to belong_to(:bank_transaction_rule) }
    it { expect(bank_transaction_rule_document_line).to belong_to(:account) }

    it { expect(bank_transaction_rule_document_line).to have_many(:bank_transaction_rule_document_line_taxes) }
  end

  context 'validations' do
    let(:bank_transaction_rule_document_line) { FactoryBot.build(:bank_transaction_rule_document_line) }

    it { expect(bank_transaction_rule_document_line).to validate_presence_of(:bank_transaction_rule) }
    it { expect(bank_transaction_rule_document_line).to validate_presence_of(:account) }

    it {
      expect(bank_transaction_rule_document_line).to accept_nested_attributes_for(:bank_transaction_rule_document_line_taxes).allow_destroy(true)
    }
  end

  context 'callbacks' do
    let(:bank_transaction_rule_document_line) { FactoryBot.build(:bank_transaction_rule_document_line) }

    it { expect(bank_transaction_rule_document_line).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule_document_line).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:bank_transaction_rule_document_line) { FactoryBot.create(:bank_transaction_rule_document_line) }
      before(:each) { bank_transaction_rule_document_line.update(updated_at: DateTime.now.zone) }

      it { expect(bank_transaction_rule_document_line.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:bank_transaction_rule_document_line) { FactoryBot.create(:bank_transaction_rule_document_line) }
      before(:each) { bank_transaction_rule_document_line.destroy }

      it { expect(bank_transaction_rule_document_line.errors.size).to eq(0) }
    end
  end
end
