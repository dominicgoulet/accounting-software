# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                 :uuid             not null, primary key
#  name               :string
#  setup_completed_at :datetime
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Organization do
  context 'has a valid factory' do
    let(:organization) { FactoryBot.build(:organization) }

    it { expect(organization).to be_valid }
  end

  context 'associations' do
    let(:organization) { FactoryBot.build(:organization) }

    it { expect(organization).to have_many(:memberships) }
    it { expect(organization).to have_many(:users).through(:memberships) }
    it { expect(organization).to have_many(:roles) }
    it { expect(organization).to have_many(:business_units) }
    it { expect(organization).to have_many(:permissions) }

    it { expect(organization).to have_many(:integrations) }
    it { expect(organization).to have_many(:audit_events) }

    it { expect(organization).to have_many(:contacts) }
    it { expect(organization).to have_many(:accounts) }
    it { expect(organization).to have_many(:journal_entries) }
    it { expect(organization).to have_many(:sales_taxes) }
    it { expect(organization).to have_many(:items) }

    it { expect(organization).to have_many(:commercial_documents) }
    it { expect(organization).to have_many(:payments).through(:commercial_documents) }
    it { expect(organization).to have_many(:purchase_orders) }
    it { expect(organization).to have_many(:bills) }
    it { expect(organization).to have_many(:expenses) }
    it { expect(organization).to have_many(:estimates) }
    it { expect(organization).to have_many(:invoices) }
    it { expect(organization).to have_many(:deposits) }
    it { expect(organization).to have_many(:transfers) }

    it { expect(organization).to have_many(:bank_credentials) }
    it { expect(organization).to have_many(:bank_accounts) }
    it { expect(organization).to have_many(:bank_transactions) }
    it { expect(organization).to have_many(:bank_transaction_rules) }
    it { expect(organization).to have_many(:bank_transaction_rule_matches) }

    it { expect(organization).to have_many(:outgoing_emails) }
    it { expect(organization).to have_many(:recurring_events) }
  end

  context 'validations' do
    let(:organization) { FactoryBot.build(:organization) }

    it { expect(organization).to validate_presence_of(:name) }
    it { expect(organization).to validate_length_of(:name).is_at_most(255) }
    it { expect(organization).to validate_length_of(:website).is_at_most(255) }
  end

  context 'callbacks' do
    let(:organization) { FactoryBot.create(:organization) }

    it { expect(organization).to callback(:setup).after(:create) }
    it { expect(organization).to callback(:can_update?).before(:update) }
    it { expect(organization).to callback(:can_delete?).before(:destroy) }

    context 'setup was completed' do
      it { expect(organization.integrations.size).to eq(1) }
      it { expect(organization.contacts.size).to eq(1) }
      it { expect(organization.accounts.size).to eq(9) }
    end
  end

  context 'methods' do
    context 'setup_completed' do
      let(:organization) { FactoryBot.create(:organization) }

      context 'initial state' do
        it { expect(organization.setup_completed_at).to be_nil }
        it { expect(organization.setup_completed?).to be_falsey }
        it { expect(organization.setup_completed!).to be_truthy }

        context 'then marking as completed' do
          before(:each) { organization.setup_completed! }

          context 'should change state' do
            it { expect(organization.setup_completed_at).not_to be_nil }
            it { expect(organization.setup_completed?).to be_truthy }
            it { expect(organization.setup_completed!).to be_falsey }
          end
        end
      end
    end

    context 'member management' do
      let(:organization) { FactoryBot.create(:organization) }
      let(:user) { FactoryBot.create(:user) }
      let(:non_member_user) { FactoryBot.create(:user) }

      context 'member?' do
        it('should have no members') { expect(organization.memberships.size).to eq(0) }
        it('user should not be a member') { expect(organization.member?(user)).to be_falsey }
        it('non_member_user should not be a member') { expect(organization.member?(non_member_user)).to be_falsey }

        context 'add_member!' do
          before(:each) { organization.add_member!(user) }

          it('should have 1 member') { expect(organization.memberships.size).to eq(1) }
          it('membership should be confirmed') { expect(organization.memberships.first.confirmed?).to be_truthy }

          it('user should be a member') { expect(organization.member?(user)).to be_truthy }
          it('non_member_user should not be a member') { expect(organization.member?(non_member_user)).to be_falsey }

          context 'remove_member!' do
            before(:each) { organization.remove_member!(user) }

            it('should have no members') { expect(organization.memberships.size).to eq(0) }
            it('user should not be a member') { expect(organization.member?(user)).to be_falsey }
            it('non_member_user should not be a member') { expect(organization.member?(non_member_user)).to be_falsey }
          end

          context 'level management' do
            it('member level should default ot member') { expect(organization.memberships.first.level).to eq('member') }

            context 'promote!' do
              before(:each) { organization.promote!(user) }

              it('member level should now be admin') { expect(organization.memberships.first.level).to eq('admin') }

              context 'demote!' do
                before(:each) { organization.demote!(user) }

                it('member level should be back to member') {
                  expect(organization.memberships.first.level).to eq('member')
                }
              end
            end

            context 'define_owner!' do
              before(:each) { organization.define_owner!(user) }

              it('member level should now be owner') { expect(organization.memberships.first.level).to eq('owner') }
              it('cannot be promoted') { expect(organization.promote!(user)).to be_falsey }
              it('cannot be demoted') { expect(organization.demote!(user)).to be_falsey }
            end
          end
        end
      end
    end

    context 'cannot be deleted' do
      let(:organization) { FactoryBot.create(:organization) }

      before(:each) { organization.destroy }

      it { expect(organization.errors.size).to eq(1) }
    end
  end
end
