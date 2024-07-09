# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_document_line_taxes
#
#  id                                     :uuid             not null, primary key
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  bank_transaction_rule_document_line_id :uuid
#  sales_tax_id                           :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRuleDocumentLineTax do
  context 'has a valid factory' do
    let(:bank_transaction_rule_document_line_tax) { FactoryBot.build(:bank_transaction_rule_document_line_tax) }

    it { expect(bank_transaction_rule_document_line_tax).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule_document_line_tax) { FactoryBot.build(:bank_transaction_rule_document_line_tax) }

    it { expect(bank_transaction_rule_document_line_tax).to belong_to(:bank_transaction_rule_document_line) }
    it { expect(bank_transaction_rule_document_line_tax).to belong_to(:sales_tax) }
  end

  context 'validations' do
    let(:bank_transaction_rule_document_line_tax) { FactoryBot.build(:bank_transaction_rule_document_line_tax) }

    it { expect(bank_transaction_rule_document_line_tax).to validate_presence_of(:bank_transaction_rule_document_line) }
    it { expect(bank_transaction_rule_document_line_tax).to validate_presence_of(:sales_tax) }
  end

  context 'callbacks' do
    let(:bank_transaction_rule_document_line_tax) { FactoryBot.build(:bank_transaction_rule_document_line_tax) }

    it { expect(bank_transaction_rule_document_line_tax).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule_document_line_tax).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:bank_transaction_rule_document_line_tax) { FactoryBot.create(:bank_transaction_rule_document_line_tax) }
      before(:each) { bank_transaction_rule_document_line_tax.update(updated_at: DateTime.now.zone) }

      it { expect(bank_transaction_rule_document_line_tax.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:bank_transaction_rule_document_line_tax) { FactoryBot.create(:bank_transaction_rule_document_line_tax) }
      before(:each) { bank_transaction_rule_document_line_tax.destroy }

      it { expect(bank_transaction_rule_document_line_tax.errors.size).to eq(0) }
    end
  end
end
