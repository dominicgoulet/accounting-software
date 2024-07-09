# frozen_string_literal: true

# == Schema Information
#
# Table name: account_taxes
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :uuid
#  sales_tax_id :uuid
#
require 'rails_helper'

RSpec.describe AccountTax do
  context 'has a valid factory' do
    let(:account_tax) { FactoryBot.build(:account_tax) }

    it { expect(account_tax).to be_valid }
  end

  context 'associations' do
    let(:account_tax) { FactoryBot.build(:account_tax) }

    it { expect(account_tax).to belong_to(:account) }
    it { expect(account_tax).to belong_to(:sales_tax) }
  end

  context 'validations' do
    let(:account_tax) { FactoryBot.build(:account_tax) }

    it { expect(account_tax).to validate_presence_of(:account) }
    it { expect(account_tax).to validate_presence_of(:sales_tax) }
  end

  context 'callbacks' do
    let(:account_tax) { FactoryBot.build(:account_tax) }

    it { expect(account_tax).to callback(:can_update?).before(:update) }
    it { expect(account_tax).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:account_tax) { FactoryBot.create(:account_tax) }
      before(:each) { account_tax.update(updated_at: DateTime.now.zone) }

      it { expect(account_tax.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:account_tax) { FactoryBot.create(:account_tax) }
      before(:each) { account_tax.destroy }

      it { expect(account_tax.errors.size).to eq(0) }
    end
  end
end
