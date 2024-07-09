# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                 :uuid             not null, primary key
#  addressable_type   :string
#  city               :string
#  country            :string
#  line1              :string
#  line2              :string
#  state_or_province  :string
#  zip_or_postal_code :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  addressable_id     :uuid
#
require 'rails_helper'

RSpec.describe Address do
  context 'has a valid factory' do
    let(:address) { FactoryBot.build(:address) }

    it { expect(address).to be_valid }
  end

  context 'associations' do
    let(:address) { FactoryBot.build(:address) }

    it { expect(address).to belong_to(:addressable) }
  end

  context 'validations' do
    let(:address) { FactoryBot.build(:address) }

    it { expect(address).to validate_presence_of(:addressable) }
  end

  context 'callbacks' do
    let(:address) { FactoryBot.build(:address) }

    it { expect(address).to callback(:can_update?).before(:update) }
    it { expect(address).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:address) { FactoryBot.create(:address) }
      before(:each) { address.update(updated_at: DateTime.now.zone) }

      it { expect(address.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:address) { FactoryBot.create(:address) }
      before(:each) { address.destroy }

      it { expect(address.errors.size).to eq(0) }
    end
  end
end
