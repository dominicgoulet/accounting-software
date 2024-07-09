# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::JournalEntriesController do
  context 'GET /journal_entries' do
    describe 'without autorization token' do
      before(:each) { get :index }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
      before(:each) { authenticate(integration) }
      before(:each) { get :index }

      it { should respond_with 200 }

      describe 'returns a json of all your journal_entries' do
        it { expect(json).to have_json_size(1) }
        it { expect(json).to include_json(integration.organization.journal_entries.first.to_json) }
      end
    end
  end

  context 'POST /journal_entries' do
    describe 'without autorization token' do
      before(:each) { post :create }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid journal_entry information' do
        before(:each) { post :create }

        it { should respond_with 422 }

        describe 'returns an error' do
          it { expect(json).to have_json_size(1) }
          it { expect(json).to be_json_eql(%({"date":["can't be blank"]})) }
        end
      end

      describe 'with valid journal_entry information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { post :create, params: { journal_entry: { date: Date.today } } }

        it { should respond_with 201 }

        describe 'adds to the journal_entries collection' do
          before(:each) { get :index }

          it { should respond_with 200 }

          describe 'GET / returns the new journal_entry' do
            it { expect(integration.organization.journal_entries.size).to eq(2) }
            it { expect(json).to have_json_size(2) }
            it { expect(json).to include_json(integration.organization.journal_entries.first.to_json) }
            it { expect(json).to include_json(integration.organization.journal_entries.last.to_json) }
          end
        end
      end
    end
  end

  context 'GET /journal_entries/:id' do
    describe 'without autorization token' do
      before(:each) { get :show, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
      before(:each) { authenticate(integration) }

      describe 'with invalid journal_entry id' do
        before(:each) { get :show, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid journal_entry id ' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
        before(:each) { authenticate(integration) }
        before(:each) { get :show, params: { id: integration.organization.journal_entries.first.id } }

        it { should respond_with 200 }

        describe 'returns journal_entry information' do
          it { expect(json).to be_json_eql(integration.organization.journal_entries.first.to_json) }
        end
      end
    end
  end

  context 'PATCH /journal_entries/:id' do
    describe 'without autorization token' do
      before(:each) { patch :update, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid journal_entry id' do
        before(:each) { patch :update, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid journal_entry id and invalid journal_entry information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.journal_entries.first.id, journal_entry: { date: '' } }
        end

        it { should respond_with 422 }
      end

      describe 'with valid journal_entry id and valid journal_entry information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update,
                params: { id: integration.organization.journal_entries.first.id,
                          journal_entry: { date: Date.today + 1 } }
        end

        it { should respond_with 204 }
      end
    end
  end

  context 'DELETE /journal_entries/:id' do
    describe 'without autorization token' do
      before(:each) { delete :destroy, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
      before(:each) { authenticate(integration) }

      let(:to_be_deleted) do
        integration.organization.journal_entries.create(integration:, date: Date.today)
      end

      describe 'with invalid journal_entry id' do
        before(:each) { delete :destroy, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid journal_entry id' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.journal_entries.create(integration:, date: Date.today) }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 204 }
      end

      describe 'with valid journal_entry id but a journal_entry that cannot be deleted' do
        let(:integration) { FactoryBot.create(:integration) }
        let(:invoice) { FactoryBot.create(:invoice) }

        let(:cannot_be_deleted) do
          integration.organization.journal_entries.create(integration:, date: Date.today, journalable: invoice)
        end

        before(:each) { authenticate(integration) }

        context 'delete' do
          before(:each) { delete :destroy, params: { id: cannot_be_deleted.id } }

          it { should respond_with 422 }
        end
      end
    end
  end
end
