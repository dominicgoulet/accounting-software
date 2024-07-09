# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id                :uuid             not null, primary key
#  confirmed_at      :datetime
#  last_logged_in_at :datetime
#  level             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :uuid             not null
#  user_id           :uuid             not null
#
require 'rails_helper'

RSpec.describe Membership do
  context 'has a valid factory' do
    let(:membership) { FactoryBot.build(:membership) }

    it { expect(membership).to be_valid }
  end

  context 'associations' do
    let(:membership) { FactoryBot.build(:membership) }

    it { expect(membership).to belong_to(:user) }
    it { expect(membership).to belong_to(:organization) }

    it { expect(membership).to have_many(:role_members) }
    it { expect(membership).to have_many(:roles).through(:role_members) }
  end

  context 'validations' do
    let(:membership) { FactoryBot.build(:membership) }

    it { expect(membership).to validate_presence_of(:user) }
    it { expect(membership).to validate_presence_of(:organization) }

    it { expect(membership).to enumerize(:level).in(:owner, :admin, :member).with_default(:member) }
  end

  context 'callbacks' do
    let(:membership) { FactoryBot.build(:membership) }

    it { expect(membership).to callback(:can_update?).before(:update) }
    it { expect(membership).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.display_name' do
        let(:membership) { FactoryBot.create(:membership) }

        it { expect(membership.display_name).to eq(membership.user.display_name) }
      end

      context '.classification' do
        let(:membership) { FactoryBot.create(:membership) }

        it { expect(membership.classification).to be_nil }
      end
    end

    context 'confirmation' do
      let(:membership) { FactoryBot.create(:membership) }

      it { expect(membership.confirmed?).to be_falsey }

      context 'when confirming' do
        before(:each) { membership.confirm! }

        it { expect(membership.confirmed?).to be_truthy }
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:membership) { FactoryBot.create(:membership) }
      before(:each) { membership.update(updated_at: DateTime.now.zone) }

      it { expect(membership.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when member' do
        let(:membership) { FactoryBot.create(:membership, level: :member) }
        before(:each) { membership.destroy }

        it { expect(membership.errors.size).to eq(0) }
      end

      context 'when member' do
        let(:membership) { FactoryBot.create(:membership, level: :admin) }
        before(:each) { membership.destroy }

        it { expect(membership.errors.size).to eq(0) }
      end

      context 'when owner' do
        let(:membership) { FactoryBot.create(:membership, level: :owner) }
        before(:each) { membership.destroy }

        it { expect(membership.errors.size).to eq(1) }
      end
    end
  end
end
