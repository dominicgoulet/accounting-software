# frozen_string_literal: true

# == Schema Information
#
# Table name: audit_events
#
#  id              :uuid             not null, primary key
#  action          :string
#  auditable_type  :string
#  current_value   :jsonb
#  occured_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auditable_id    :uuid
#  integration_id  :uuid             not null
#  organization_id :uuid             not null
#  user_id         :uuid
#
require 'rails_helper'

RSpec.describe AuditEvent do
  context 'has a valid factory' do
    let(:audit_event) { FactoryBot.build(:audit_event) }

    it { expect(audit_event).to be_valid }
  end

  context 'associations' do
    let(:audit_event) { FactoryBot.build(:audit_event) }

    it { expect(audit_event).to belong_to(:integration) }
    it { expect(audit_event).to belong_to(:organization) }
    it { expect(audit_event).to belong_to(:auditable) }
    it { expect(audit_event).to belong_to(:user).optional }
  end

  context 'validations' do
    let(:audit_event) { FactoryBot.build(:audit_event) }

    it { expect(audit_event).to validate_presence_of(:integration) }
    it { expect(audit_event).to validate_presence_of(:organization) }
    it { expect(audit_event).to validate_presence_of(:auditable) }
    it { expect(audit_event).to validate_presence_of(:action) }
  end

  context 'callbacks' do
    let(:audit_event) { FactoryBot.build(:audit_event) }

    it { expect(audit_event).to callback(:can_update?).before(:update) }
    it { expect(audit_event).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'changes_from_previous_version' do
      let(:item) { FactoryBot.create(:item) }
      let(:integration) { FactoryBot.create(:integration) }

      before(:each) { integration.log_event(item, 'create') }

      it { expect(integration.audit_events.order('created_at desc').first.changes_from_previous_version).not_to be_nil }

      context 'when making changes' do
        before(:each) { item.name = 'Lightsaber' }
        before(:each) { integration.log_event(item, 'update') }

        it {
          expect(integration.audit_events.order('created_at desc').first.changes_from_previous_version).to eq([{
                                                                                                                is: 'Lightsaber', property: 'name', was: 'My item'
                                                                                                              }])
        }
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:audit_event) { FactoryBot.create(:audit_event) }
      before(:each) { audit_event.update(updated_at: DateTime.now.zone) }

      it { expect(audit_event.errors.size).to eq(1) }
    end

    context 'delete' do
      let(:audit_event) { FactoryBot.create(:audit_event) }
      before(:each) { audit_event.destroy }

      it { expect(audit_event.errors.size).to eq(1) }
    end
  end
end
