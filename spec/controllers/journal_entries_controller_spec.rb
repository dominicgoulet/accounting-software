# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JournalEntriesController do
  before(:each) { create_and_login }

  describe 'GET /journal_entries' do
    context 'with valid information' do
      it 'will render all journal_entries' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /journal_entries/:id' do
    context 'with a valid identifier' do
      let(:journal_entry) { FactoryBot.create(:journal_entry, organization: current_organization) }

      it 'renders the view' do
        get :show, params: { id: journal_entry.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :show, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /journal_entries/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /journal_entries' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          journal_entry: {
            date: Date.today
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new journal_entry' do
        expect do
          post :create, params: {
            journal_entry: {
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(JournalEntry, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            journal_entry: {
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          journal_entry: {
            date: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new journal_entry' do
        expect do
          post :create, params: {
            journal_entry: {
              date: ''
            }
          }, format: :html
        end.not_to change(JournalEntry, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            journal_entry: {
              date: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /journal_entries/:id/edit' do
    context 'with a valid identifier' do
      let(:journal_entry) { FactoryBot.create(:journal_entry, organization: current_organization) }

      it 'renders the view' do
        get :edit, params: { id: journal_entry.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :edit, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /journal_entries/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:journal_entry) { FactoryBot.create(:journal_entry, organization: current_organization) }

      it 'renders the view' do
        patch :update, params: { id: journal_entry.id, journal_entry: { date: Date.today - 1 } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the journal_entry' do
        patch :update, params: { id: journal_entry.id, journal_entry: { date: Date.today - 1 } }, format: :turbo_stream
        journal_entry.reload

        expect(journal_entry.date).to eq(Date.today - 1)
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: journal_entry.id, journal_entry: {
              date: Date.today - 1
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:journal_entry) { FactoryBot.create(:journal_entry, organization: current_organization) }

      it 'renders the view' do
        patch :update, params: { id: journal_entry.id, journal_entry: { date: '' } }

        expect(response).to have_http_status(422)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :update, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /journal_entries/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        journal_entry = FactoryBot.create(:journal_entry, organization: current_organization)

        delete :destroy, params: { id: journal_entry.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the journal_entry' do
        journal_entry = FactoryBot.create(:journal_entry, organization: current_organization)

        expect do
          delete :destroy, params: { id: journal_entry.id }, format: :turbo_stream
        end.to change(JournalEntry, :count)
      end

      it 'creates an audit event' do
        journal_entry = FactoryBot.create(:journal_entry, organization: current_organization)

        expect do
          delete :destroy, params: {
            id: journal_entry.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the journal_entry' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(JournalEntry, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: 'invalid-id'
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'DELETE /journal_entries' do
    context 'with valid ids' do
      it 'renders the view' do
        journal_entry_1 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_2 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_3 = FactoryBot.create(:journal_entry, organization: current_organization)

        delete :destroy_many, params: {
          item_ids: [journal_entry_1.id, journal_entry_2.id, journal_entry_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the journal_entries' do
        journal_entry_1 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_2 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_3 = FactoryBot.create(:journal_entry, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [journal_entry_1.id, journal_entry_2.id, journal_entry_3.id]
          }, format: :turbo_stream
        end.to change(JournalEntry, :count).by(-3)
      end

      it 'creates an audit event per journal_entry deleted' do
        journal_entry_1 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_2 = FactoryBot.create(:journal_entry, organization: current_organization)
        journal_entry_3 = FactoryBot.create(:journal_entry, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [journal_entry_1.id, journal_entry_2.id, journal_entry_3.id]
          }, format: :turbo_stream
        end.to change(AuditEvent, :count).by(3)
      end
    end

    context 'with invalid ids' do
      it 'renders the view' do
        delete :destroy_many, params: {
          item_ids: %w[invalid-id-1 invalid-id-2]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the journal_entries' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(JournalEntry, :count)
      end

      it 'does not creates an audit event per journal_entry deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
