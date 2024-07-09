# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id              :uuid             not null, primary key
#  description     :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
require 'rails_helper'

RSpec.describe Role do
  context 'has a valid factory' do
    let(:role) { FactoryBot.build(:role) }

    it { expect(role).to be_valid }
  end

  context 'associations' do
    let(:role) { FactoryBot.build(:role) }

    it { expect(role).to belong_to(:organization) }

    it { expect(role).to have_many(:permissions) }
    it { expect(role).to have_many(:role_members) }
    it { expect(role).to have_many(:memberships).through(:role_members) }
  end

  context 'validations' do
    let(:role) { FactoryBot.build(:role) }

    it { expect(role).to validate_presence_of(:organization) }
    it { expect(role).to validate_presence_of(:name) }
  end

  context 'callbacks' do
    let(:role) { FactoryBot.build(:role) }

    it { expect(role).to callback(:setup_permissions).after(:create) }
    it { expect(role).to callback(:can_update?).before(:update) }
    it { expect(role).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:role) { FactoryBot.create(:role) }
      before(:each) { role.update(updated_at: DateTime.now.zone) }

      it { expect(role.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:role) { FactoryBot.create(:role) }
      before(:each) { role.destroy }

      it { expect(role.errors.size).to eq(0) }
    end
  end
end
