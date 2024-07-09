# frozen_string_literal: true

# == Schema Information
#
# Table name: business_units
#
#  id                      :uuid             not null, primary key
#  description             :string
#  full_path               :string
#  internal_code           :string
#  name                    :string
#  system                  :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :uuid
#  parent_business_unit_id :uuid
#
require 'rails_helper'

RSpec.describe BusinessUnit do
  context 'has a valid factory' do
    let(:business_unit) { FactoryBot.build(:business_unit) }

    it { expect(business_unit).to be_valid }
  end

  context 'associations' do
    let(:business_unit) { FactoryBot.build(:business_unit) }

    it { expect(business_unit).to belong_to(:organization) }
    it { expect(business_unit).to belong_to(:parent_business_unit).optional }

    it { expect(business_unit).to have_many(:permissions) }
    it { expect(business_unit).to have_many(:child_business_units) }
  end

  context 'validations' do
    let(:business_unit) { FactoryBot.create(:business_unit) }

    it { expect(business_unit).to validate_presence_of(:organization) }
    it { expect(business_unit).to validate_presence_of(:name) }

    context 'parent_business_unit_cannot_be_itself_or_a_child' do
      context 'with no parent' do
        it { expect(business_unit.errors.size).to eq(0) }
      end

      context 'with self as a parent' do
        before(:each) { business_unit.update(parent_business_unit: business_unit) }

        it { expect(business_unit.errors.size).to eq(1) }
      end

      context 'with child as a parent' do
        let(:child_business_unit) { FactoryBot.create(:business_unit, parent_business_unit: business_unit) }

        before(:each) { business_unit.update(parent_business_unit: child_business_unit) }
        it { expect(business_unit.errors.size).to eq(1) }
      end

      context 'with child of a child as a parent' do
        let(:child_business_unit) { FactoryBot.create(:business_unit, parent_business_unit: business_unit) }
        let(:child_of_a_child_business_unit) do
          FactoryBot.create(:business_unit, parent_business_unit: child_business_unit)
        end

        before(:each) { business_unit.update(parent_business_unit: child_of_a_child_business_unit) }
        it { expect(business_unit.errors.size).to eq(1) }
      end

      context 'with any other unrelated as a parent' do
        let(:unrelated_business_unit) { FactoryBot.create(:business_unit) }
        before(:each) { business_unit.update(parent_business_unit: unrelated_business_unit) }

        it { expect(business_unit.errors.size).to eq(0) }
      end
    end
  end

  context 'callbacks' do
    let(:business_unit) { FactoryBot.create(:business_unit) }

    it { expect(business_unit).to callback(:setup_permissions).after(:create) }
    it { expect(business_unit).to callback(:can_update?).before(:update) }
    it { expect(business_unit).to callback(:can_delete?).before(:destroy) }

    it { expect(business_unit).to callback(:update_full_path).before(:save) }
    it { expect(business_unit).to callback(:update_child_business_units).after(:save) }
    it { expect(business_unit).to callback(:update_child_business_units).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.display_name' do
        let(:business_unit) { FactoryBot.create(:business_unit) }

        it { expect(business_unit.display_name).to eq(business_unit.name) }
      end

      context '.classification' do
        let(:business_unit) { FactoryBot.create(:business_unit) }

        it { expect(business_unit.classification).to be_nil }
      end
    end

    context 'parent_business_units' do
      let(:business_unit) { FactoryBot.create(:business_unit) }

      it { expect(business_unit.parent_business_units).to eq([]) }

      context 'when adding a parent' do
        let(:parent_business_unit) { FactoryBot.create(:business_unit) }
        before(:each) { business_unit.update(parent_business_unit:) }

        it { expect(business_unit.parent_business_units).to eq([parent_business_unit]) }

        context 'when adding a grandparent to the parent' do
          let(:grandparent_business_unit) { FactoryBot.create(:business_unit) }
          before(:each) { parent_business_unit.update(parent_business_unit: grandparent_business_unit) }

          it { expect(business_unit.parent_business_units).to eq([grandparent_business_unit, parent_business_unit]) }
        end
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:business_unit) { FactoryBot.create(:business_unit) }
      before(:each) { business_unit.update(updated_at: DateTime.now.zone) }

      it { expect(business_unit.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when system? is false' do
        let(:business_unit) { FactoryBot.create(:business_unit) }
        before(:each) { business_unit.destroy }

        it { expect(business_unit.errors.size).to eq(0) }
      end

      context 'when system? is true' do
        let(:business_unit) { FactoryBot.create(:business_unit, system: true) }
        before(:each) { business_unit.destroy }

        it { expect(business_unit.errors.size).to eq(1) }
      end
    end
  end
end
