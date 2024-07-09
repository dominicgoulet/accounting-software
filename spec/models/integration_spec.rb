# frozen_string_literal: true

# == Schema Information
#
# Table name: integrations
#
#  id                    :uuid             not null, primary key
#  internal_code         :string
#  name                  :string
#  secret_key_bidx       :string
#  secret_key_ciphertext :text
#  subscribed_webhooks   :string           default([]), is an Array
#  system                :boolean          default(FALSE)
#  webhook_url           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  organization_id       :uuid             not null
#
require 'rails_helper'

RSpec.describe Integration do
  context 'class methods' do
    context '#available_webhooks' do
      it { expect(Integration.available_webhooks.size).to be > 1 }
    end
  end

  context 'has a valid factory' do
    let(:integration) { FactoryBot.build(:integration) }

    it { expect(integration).to be_valid }
  end

  context 'associations' do
    let(:integration) { FactoryBot.build(:integration) }

    it { expect(integration).to belong_to(:organization) }
    it { expect(integration).to have_many(:journal_entries) }
    it { expect(integration).to have_many(:audit_events) }
  end

  context 'validations' do
    let(:integration) { FactoryBot.build(:integration) }

    it { expect(integration).to validate_presence_of(:organization) }
    it { expect(integration).to validate_presence_of(:name) }
    it { expect(integration).to validate_uniqueness_of(:secret_key) }
  end

  context 'callbacks' do
    let(:integration) { FactoryBot.build(:integration) }

    it { expect(integration).to callback(:generate_secret_key).before(:create) }
    it { expect(integration).to callback(:can_update?).before(:update) }
    it { expect(integration).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context '.icon default value' do
      let(:integration) { FactoryBot.create(:integration) }

      it { expect(integration.icon).to eq('integrations/custom') }
    end

    context '.journalable_types' do
      let(:integration) { FactoryBot.create(:integration) }

      it { expect(integration.journalable_types).to eq([]) }
    end

    context '.log_event' do
      context 'without an auditable' do
        let(:integration) { FactoryBot.create(:integration) }

        it { expect(integration.log_event(nil, 'create')).to be_falsey }
      end

      context 'without an action' do
        let(:integration) { FactoryBot.create(:integration) }
        let(:auditable) { FactoryBot.create(:contact) }

        it { expect(integration.log_event(auditable, nil)).to be_falsey }
      end

      context 'with an auditable and an action' do
        let(:integration) { FactoryBot.create(:integration) }
        let(:auditable) { FactoryBot.create(:contact) }

        it { expect(integration.log_event(auditable, 'create')).to be_truthy }
      end
    end

    context '.setup_specific_integration' do
      context 'with NINETYFOUR integration_type' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.setup_specific_integration('NINETYFOUR') }

        it { expect(integration.internal_code).to eq('NINETYFOUR') }
        it { expect(integration.icon).to eq('integrations/ninetyfour') }
      end

      context 'with QUICKBOOKS integration_type' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.setup_specific_integration('QUICKBOOKS') }

        it { expect(integration.internal_code).to eq('QUICKBOOKS') }
        it { expect(integration.icon).to eq('integrations/quickbooks') }
      end

      context 'with XERO integration_type' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.setup_specific_integration('XERO') }

        it { expect(integration.internal_code).to eq('XERO') }
        it { expect(integration.icon).to eq('integrations/xero') }
      end

      context 'with CUSTOM integration_type' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.setup_specific_integration('CUSTOM') }

        it { expect(integration.internal_code).to be_nil }
        it { expect(integration.icon).to eq('integrations/custom') }
      end
    end
  end

  context 'custom integration' do
    let(:integration) { FactoryBot.create(:integration) }

    it 'system? is false' do
      expect(integration.system?).to be_falsey
    end

    it 'can be updated' do
      expect { integration.update(name: 'new name') }.not_to raise_error
    end

    it 'can be deleted' do
      expect { integration.destroy }.not_to raise_error
    end
  end

  context 'system integration' do
    context 'system? is true' do
      let(:integration) { FactoryBot.create(:integration, system: true) }

      it { expect(integration.system?).to be_truthy }
    end

    context 'cannot be updated' do
      let(:integration) { FactoryBot.create(:integration, system: true) }
      before(:each) { integration.update(name: 'new name') }

      it { expect(integration.errors.size).to eq(1) }
    end

    context 'cannot be deleted' do
      let(:integration) { FactoryBot.create(:integration, system: true) }
      before(:each) { integration.destroy }

      it { expect(integration.errors.size).to eq(1) }
    end
  end
end
