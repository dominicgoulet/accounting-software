# frozen_string_literal: true

# == Schema Information
#
# Table name: permissions
#
#  id               :uuid             not null, primary key
#  level            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_unit_id :uuid
#  organization_id  :uuid
#  role_id          :uuid
#
require 'rails_helper'

RSpec.describe Permission do
  context 'class methods' do
    context '#init_permissions_for_organization' do
      let(:organization) { FactoryBot.create(:organization) }

      before(:each) { organization.roles.create(name: 'Jedi') }
      before(:each) { organization.business_units.create(name: 'Death Star') }
      before(:each) { Permission.init_permissions_for_organization(organization) }

      it { expect(organization.roles.size).to eq(1) }
      it { expect(organization.business_units.size).to eq(1) }
      it { expect(organization.permissions.size).to eq(1) }
    end
  end

  context 'has a valid factory' do
    let(:permission) { FactoryBot.build(:permission) }

    it { expect(permission).to be_valid }
  end

  context 'associations' do
    let(:permission) { FactoryBot.build(:permission) }

    it { expect(permission).to belong_to(:organization) }
    it { expect(permission).to belong_to(:role) }
    it { expect(permission).to belong_to(:business_unit) }
  end

  context 'validations' do
    let(:permission) { FactoryBot.build(:permission) }

    it { expect(permission).to validate_presence_of(:organization) }
    it { expect(permission).to validate_presence_of(:role) }
    it { expect(permission).to validate_presence_of(:business_unit) }

    it { expect(permission).to enumerize(:level).in(:none, :view, :edit).with_default(:none) }
  end

  context 'callbacks' do
    let(:permission) { FactoryBot.build(:permission) }

    it { expect(permission).to callback(:can_update?).before(:update) }
    it { expect(permission).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.image' do
        context 'when level = none' do
          let(:permission) { FactoryBot.create(:permission, level: :none) }

          it { expect(permission.image).to eq('mini/eye-slash') }
        end

        context 'when level = view' do
          let(:permission) { FactoryBot.create(:permission, level: :view) }

          it { expect(permission.image).to eq('mini/eye') }
        end

        context 'when level = edit' do
          let(:permission) { FactoryBot.create(:permission, level: :edit) }

          it { expect(permission.image).to eq('mini/pencil-square') }
        end

        context 'when level = unknown' do
          let(:permission) { FactoryBot.build(:permission, level: :unknown) }

          it { expect(permission.image).to eq('mini/question-mark-circle') }
        end
      end
    end

    context 'levels' do
      context '.permission_level_none!' do
        let(:permission) { FactoryBot.create(:permission) }
        before(:each) { permission.permission_level_none! }

        it { expect(permission.level).to eq(:none) }
      end

      context '.permission_level_view!' do
        let(:permission) { FactoryBot.create(:permission) }
        before(:each) { permission.permission_level_view! }

        it { expect(permission.level).to eq(:view) }
      end

      context '.permission_level_edit!' do
        let(:permission) { FactoryBot.create(:permission) }
        before(:each) { permission.permission_level_edit! }

        it { expect(permission.level).to eq(:edit) }
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:permission) { FactoryBot.create(:permission) }
      before(:each) { permission.update(updated_at: DateTime.now.zone) }

      it { expect(permission.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:permission) { FactoryBot.create(:permission) }
      before(:each) { permission.destroy }

      it { expect(permission.errors.size).to eq(0) }
    end
  end
end
