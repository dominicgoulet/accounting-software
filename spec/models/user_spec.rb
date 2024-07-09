# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  password_digest        :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  setup_completed_at     :datetime
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

RSpec.describe User do
  context 'class methods' do
    let(:user) { FactoryBot.create(:user) }

    context '#authenticate_with_email_and_password' do
      it { expect(User.authenticate_with_email_and_password(user.email, '0000', '127.0.0.1')).to be_truthy }
    end

    context '#reset_password_with_token!' do
      before(:each) { user.send_reset_password_instructions! }

      it { expect(User.reset_password_with_token!(user.reset_password_token, '1111')).to be_truthy }
    end

    context '#find_or_create_with_random_password' do
      it { expect(User.find_or_create_with_random_password('special_email@email.com')).to be_truthy }
    end
  end

  context 'has a valid factory' do
    let(:user) { FactoryBot.build(:user) }

    it { expect(user).to be_valid }
  end

  context 'associations' do
    let(:user) { FactoryBot.build(:user) }

    it { expect(user).to have_many(:memberships) }
    it { expect(user).to have_many(:organizations).through(:memberships) }
  end

  context 'validations' do
    let(:user) { FactoryBot.build(:user) }

    it { expect(user).to validate_presence_of(:email) }
    it { expect(user).to validate_uniqueness_of(:email) }
    it { expect(user).to validate_length_of(:email).is_at_most(255) }

    it { expect(user).to validate_presence_of(:password) }
  end

  context 'callbacks' do
    let(:user) { FactoryBot.build(:user) }

    it { expect(user).to callback(:create_default_organization).after(:create) }
    it { expect(user).to callback(:send_new_user_instructions).after(:create) }
    it { expect(user).to callback(:can_update?).before(:update) }
    it { expect(user).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.avatar_url' do
        let(:user) { FactoryBot.create(:user) }

        it { expect(user.avatar_url).not_to be_nil }
      end

      context '.display_name' do
        let(:user) { FactoryBot.create(:user, first_name: 'Darth', last_name: 'Vader') }

        it { expect(user.display_name).to eq('Darth Vader') }
      end
    end

    context 'confirmation' do
      let(:user) { FactoryBot.create(:user) }

      it { expect(user.confirmed?).to be_falsey }

      context 'when doing initial confirmation' do
        before(:each) { user.confirm! }

        it { expect(user.confirmed?).to be_truthy }

        context 'when changing email' do
          before(:each) { user.change_email!('changed_email@test.org') }

          it { expect(user.confirmed?).to be_falsey }

          context 'when confirming the new email' do
            before(:each) { user.confirm! }

            it { expect(user.confirmed?).to be_truthy }
          end
        end
      end
    end

    context 'password' do
      let(:user) { FactoryBot.create(:user) }

      it { expect(user.reset_password_sent_at).to be_nil }
      it { expect(user.reset_password_token).to be_nil }

      context 'with incorrect password' do
        it { expect(user.can_update_password?('bad_password')).to be_falsey }
      end

      context 'with current password' do
        it { expect(user.can_update_password?('0000')).to be_truthy }
      end

      context 'send_reset_password_instructions!' do
        before(:each) { user.send_reset_password_instructions! }

        it { expect(user.reset_password_sent_at).not_to be_nil }
        it { expect(user.reset_password_token).not_to be_nil }
      end
    end

    context 'email' do
      let(:user) { FactoryBot.create(:user) }
      before(:each) { user.confirm! }

      it { expect(user.confirmed?).to be_truthy }
      it { expect(user.unconfirmed_email).to be_nil }

      context 'when changing email' do
        before(:each) { user.change_email!('changed_email@test.org') }

        it { expect(user.unconfirmed_email).to eq('changed_email@test.org') }
        it { expect(user.confirmed?).to be_falsey }

        context 'when confirming the change' do
          before(:each) { user.confirm! }

          it { expect(user.confirmed?).to be_truthy }
          it { expect(user.unconfirmed_email).to be_nil }
          it { expect(user.email).to eq('changed_email@test.org') }
        end

        context 'when cancelling the change' do
          before(:each) { user.cancel_change_email! }

          it { expect(user.confirmed?).to be_truthy }
          it { expect(user.unconfirmed_email).to be_nil }
        end
      end
    end

    context 'organizations' do
      let(:owner) { FactoryBot.create(:user) }
      let(:admin) { FactoryBot.create(:user) }
      let(:member) { FactoryBot.create(:user) }
      let(:organization) { FactoryBot.create(:organization) }

      context 'defaults' do
        it { expect(owner.all_organizations.size).to eq(1) }
        it { expect(owner.managed_organizations.size).to eq(1) }
        it { expect(owner.owned_organizations.size).to eq(1) }

        it { expect(admin.all_organizations.size).to eq(1) }
        it { expect(admin.managed_organizations.size).to eq(1) }
        it { expect(admin.owned_organizations.size).to eq(1) }

        it { expect(member.all_organizations.size).to eq(1) }
        it { expect(member.managed_organizations.size).to eq(1) }
        it { expect(member.owned_organizations.size).to eq(1) }
      end

      context 'when adding members' do
        before(:each) { organization.add_member!(owner) }
        before(:each) { organization.add_member!(admin) }
        before(:each) { organization.add_member!(member) }

        it { expect(member.all_organizations.size).to eq(2) }
        it { expect(member.managed_organizations.size).to eq(1) }
        it { expect(member.owned_organizations.size).to eq(1) }

        context 'when promoting admin' do
          before(:each) { organization.promote!(admin) }

          it { expect(admin.all_organizations.size).to eq(2) }
          it { expect(admin.managed_organizations.size).to eq(2) }
          it { expect(admin.owned_organizations.size).to eq(1) }
        end

        context 'when defining owner' do
          before(:each) { organization.define_owner!(owner) }

          it { expect(owner.all_organizations.size).to eq(2) }
          it { expect(owner.managed_organizations.size).to eq(2) }
          it { expect(owner.owned_organizations.size).to eq(2) }
        end
      end
    end

    context 'current_organization' do
      let(:user) { FactoryBot.create(:user) }

      it { expect(user.current_organization.name).to eq('Default organization') }

      context 'when creating a new organization' do
        let(:organization) { FactoryBot.create(:organization, name: 'The Empire') }
        before(:each) { organization.define_owner!(user) }

        it { expect(user.current_organization.name).to eq('Default organization') }

        context 'and setting it as current_organization!' do
          before(:each) { user.current_organization!(organization) }

          it { expect(user.current_organization.name).to eq('The Empire') }
        end
      end
    end

    context 'cannot be deleted' do
      let(:user) { FactoryBot.create(:user) }

      before(:each) { user.destroy }

      it { expect(user.errors.size).to eq(1) }
    end
  end
end
