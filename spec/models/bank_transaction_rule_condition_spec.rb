# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_rule_conditions
#
#  id                       :uuid             not null, primary key
#  condition                :string
#  field                    :string
#  value                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank_transaction_rule_id :uuid
#
require 'rails_helper'

RSpec.describe BankTransactionRuleCondition do
  context 'has a valid factory' do
    let(:bank_transaction_rule_condition) { FactoryBot.build(:bank_transaction_rule_condition) }

    it { expect(bank_transaction_rule_condition).to be_valid }
  end

  context 'associations' do
    let(:bank_transaction_rule_condition) { FactoryBot.build(:bank_transaction_rule_condition) }

    it { expect(bank_transaction_rule_condition).to belong_to(:bank_transaction_rule) }
  end

  context 'validations' do
    let(:bank_transaction_rule_condition) { FactoryBot.build(:bank_transaction_rule_condition) }

    it { expect(bank_transaction_rule_condition).to validate_presence_of(:bank_transaction_rule) }

    it { expect(bank_transaction_rule_condition).to enumerize(:field).in(:description, :amount).with_default(:amount) }
    it {
      expect(bank_transaction_rule_condition).to enumerize(:condition).in(:contains, :does_not_contains, :is, :lower_than,
                                                                          :greater_than).with_default(:is)
    }
  end

  context 'callbacks' do
    let(:bank_transaction_rule_condition) { FactoryBot.build(:bank_transaction_rule_condition) }

    it { expect(bank_transaction_rule_condition).to callback(:can_update?).before(:update) }
    it { expect(bank_transaction_rule_condition).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:bank_transaction_rule_condition) { FactoryBot.create(:bank_transaction_rule_condition) }
      before(:each) { bank_transaction_rule_condition.update(updated_at: DateTime.now.zone) }

      it { expect(bank_transaction_rule_condition.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:bank_transaction_rule_condition) { FactoryBot.create(:bank_transaction_rule_condition) }
      before(:each) { bank_transaction_rule_condition.destroy }

      it { expect(bank_transaction_rule_condition.errors.size).to eq(0) }
    end
  end
end
