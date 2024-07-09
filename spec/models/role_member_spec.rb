# frozen_string_literal: true

# == Schema Information
#
# Table name: role_members
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  membership_id :uuid
#  role_id       :uuid
#
require 'rails_helper'

RSpec.describe Role do
  context 'has a valid factory' do
    let(:role_member) { FactoryBot.build(:role_member) }

    it { expect(role_member).to be_valid }
  end

  context 'associations' do
    let(:role_member) { FactoryBot.build(:role_member) }

    it { expect(role_member).to belong_to(:role) }
    it { expect(role_member).to belong_to(:membership) }
  end

  context 'validations' do
    let(:role_member) { FactoryBot.build(:role_member) }

    it { expect(role_member).to validate_presence_of(:role) }
    it { expect(role_member).to validate_presence_of(:membership) }
  end

  context 'callbacks' do
    let(:role_member) { FactoryBot.build(:role_member) }

    it { expect(role_member).to callback(:can_update?).before(:update) }
    it { expect(role_member).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:role_member) { FactoryBot.create(:role_member) }
      before(:each) { role_member.update(updated_at: DateTime.now.zone) }

      it { expect(role_member.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:role_member) { FactoryBot.create(:role_member) }
      before(:each) { role_member.destroy }

      it { expect(role_member.errors.size).to eq(0) }
    end
  end
end
