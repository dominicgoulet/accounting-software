# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Accountable do
  context 'when sales tax' do
    context 'has a valid factory' do
      let(:sales_tax) { FactoryBot.build(:sales_tax) }

      it { expect(sales_tax).to be_valid }
    end

    context 'associations' do
      let(:sales_tax) { FactoryBot.build(:sales_tax) }

      it { expect(sales_tax).to have_one(:account) }
    end

    context 'validations' do
      let(:sales_tax) { FactoryBot.build(:sales_tax) }

      it { expect(sales_tax).to accept_nested_attributes_for(:account) }
    end

    context 'callbacks' do
      let(:sales_tax) { FactoryBot.build(:sales_tax) }

      it { expect(sales_tax).to callback(:create_account).after(:create) }
      it { expect(sales_tax).to callback(:update_account).after(:update) }
    end
  end

  context 'when bank account' do
    context 'has a valid factory' do
      let(:bank_account) { FactoryBot.build(:bank_account) }

      it { expect(bank_account).to be_valid }
    end

    context 'associations' do
      let(:bank_account) { FactoryBot.build(:bank_account) }

      it { expect(bank_account).to have_one(:account) }
    end

    context 'validations' do
      let(:bank_account) { FactoryBot.build(:bank_account) }

      it { expect(bank_account).to accept_nested_attributes_for(:account) }
    end

    context 'callbacks' do
      let(:bank_account) { FactoryBot.build(:bank_account) }

      it { expect(bank_account).to callback(:create_account).after(:create) }
      it { expect(bank_account).to callback(:update_account).after(:update) }
    end
  end
end
