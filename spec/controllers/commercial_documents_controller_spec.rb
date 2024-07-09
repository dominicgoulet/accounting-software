# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommercialDocumentsController do
  before(:each) { create_and_login }

  describe 'GET /commercial_documents' do
    context 'with valid information' do
      it 'will render all commercial_documents' do
        get :index, params: { type: 'Invoice' }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /commercial_documents/archives' do
    context 'with valid information' do
      it 'will render all commercial_documents archives' do
        get :archives, params: { type: 'Invoice' }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /commercial_documents/:id' do
    context 'with a valid identifier' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        get :show, params: { type: 'Invoice', id: commercial_document.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :show, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /commercial_documents/:id/prepare_email' do
    context 'with a valid identifier' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        get :prepare_email, params: { type: 'Invoice', id: commercial_document.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :prepare_email, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /commercial_documents/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new, params: { type: 'Invoice' }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /commercial_documents' do
    let(:contact) { FactoryBot.create(:contact) }

    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          type: 'Invoice',
          invoice: {
            contact_id: contact.id,
            date: Date.today
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new commercial_document' do
        expect do
          post :create, params: {
            type: 'Invoice',
            invoice: {
              contact_id: contact.id,
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(CommercialDocument, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            type: 'Invoice',
            invoice: {
              contact_id: contact.id,
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          type: 'Invoice',
          commercial_document: {
            date: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new commercial_document' do
        expect do
          post :create, params: {
            type: 'Invoice',
            commercial_document: {
              date: ''
            }
          }, format: :html
        end.not_to change(CommercialDocument, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            type: 'Invoice',
            commercial_document: {
              date: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /commercial_documents/:id/edit' do
    context 'with a valid identifier' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        get :edit, params: { type: 'Invoice', id: commercial_document.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :edit, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /commercial_documents/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        patch :update, params: {
          type: 'Invoice',
          id: commercial_document.id,
          invoice: {
            date: Date.today - 1
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the commercial_document' do
        patch :update, params: {
          type: 'Invoice',
          id: commercial_document.id,
          invoice: {
            date: Date.today - 1
          }
        }, format: :turbo_stream

        commercial_document.reload

        expect(commercial_document.date).to eq(Date.today - 1)
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            type: 'Invoice',
            id: commercial_document.id,
            invoice: {
              date: Date.today - 1
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        patch :update, params: {
          type: 'Invoice',
          id: commercial_document.id,
          invoice: {
            date: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :update, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /commercial_documents/:id/accept_draft' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        patch :accept_draft, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the commercial_document' do
        patch :accept_draft, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        commercial_document.reload

        expect(commercial_document.status).to eq('new')
      end

      it 'creates an audit event' do
        expect do
          patch :accept_draft, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :accept_draft, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /commercial_documents/:id/mark_as_sent' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        patch :mark_as_sent, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the commercial_document' do
        patch :mark_as_sent, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        commercial_document.reload

        expect(commercial_document.status).to eq('sent')
      end

      it 'creates an audit event' do
        expect do
          patch :mark_as_sent, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :mark_as_sent, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /commercial_documents/:id/return_to_draft' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        patch :return_to_draft, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the commercial_document' do
        patch :return_to_draft, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :turbo_stream

        commercial_document.reload

        expect(commercial_document.status).to eq('draft')
      end

      it 'creates an audit event' do
        expect do
          patch :return_to_draft, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :return_to_draft, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /commercial_documents/:id/send_email' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        post :send_email, params: {
          type: 'Invoice',
          id: commercial_document.id,
          outgoing_email: {
            recipients: 'test@test.org',
            subject: 'Subject',
            body: 'Body'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates an outgoing email' do
        expect do
          post :send_email, params: {
            type: 'Invoice',
            id: commercial_document.id,
            outgoing_email: {
              recipients: 'test@test.org',
              subject: 'Subject',
              body: 'Body'
            }
          }, format: :turbo_stream
        end.to change(OutgoingEmail, :count)
      end

      it 'creates an audit event' do
        expect do
          post :send_email, params: {
            type: 'Invoice',
            id: commercial_document.id,
            outgoing_email: {
              recipients: 'test@test.org',
              subject: 'Subject',
              body: 'Body'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:contact) { FactoryBot.create(:contact) }
      let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

      it 'renders the view' do
        post :send_email, params: {
          type: 'Invoice',
          id: commercial_document.id
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates an outgoing email' do
        expect do
          post :send_email, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :html
        end.not_to change(OutgoingEmail, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :send_email, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        post :send_email, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /commercial_documents/:id' do
    let(:contact) { FactoryBot.create(:contact) }

    context 'with a valid identifier' do
      it 'renders the view' do
        commercial_document = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        delete :destroy, params: { type: 'Invoice', id: commercial_document.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the commercial_document' do
        commercial_document = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        expect do
          delete :destroy, params: { type: 'Invoice', id: commercial_document.id },
                           format: :turbo_stream
        end.to change(CommercialDocument, :count)
      end

      it 'creates an audit event' do
        commercial_document = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        expect do
          delete :destroy, params: {
            type: 'Invoice',
            id: commercial_document.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { type: 'Invoice', id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the commercial_document' do
        expect do
          delete :destroy, params: { type: 'Invoice', id: 'invalid-id' },
                           format: :turbo_stream
        end.not_to change(CommercialDocument, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: { type: 'Invoice', id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'DELETE /commercial_documents' do
    let(:contact) { FactoryBot.create(:contact) }

    context 'with valid ids' do
      it 'renders the view' do
        commercial_document_1 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_2 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_3 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        delete :destroy_many, params: {
          type: 'Invoice',
          item_ids: [commercial_document_1.id, commercial_document_2.id, commercial_document_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the commercial_documents' do
        commercial_document_1 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_2 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_3 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        expect do
          delete :destroy_many, params: {
            type: 'Invoice',
            item_ids: [commercial_document_1.id, commercial_document_2.id, commercial_document_3.id]
          }, format: :turbo_stream
        end.to change(CommercialDocument, :count).by(-3)
      end

      it 'creates an audit event per commercial_document deleted' do
        commercial_document_1 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_2 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        commercial_document_3 = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')

        expect do
          delete :destroy_many, params: {
            type: 'Invoice',
            item_ids: [commercial_document_1.id, commercial_document_2.id, commercial_document_3.id]
          }, format: :turbo_stream
        end.to change(AuditEvent, :count).by(3)
      end
    end

    context 'with invalid ids' do
      it 'renders the view' do
        delete :destroy_many, params: {
          type: 'Invoice',
          item_ids: %w[invalid-id-1 invalid-id-2]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the commercial_documents' do
        expect do
          delete :destroy_many, params: {
            type: 'Invoice',
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(CommercialDocument, :count)
      end

      it 'does not creates an audit event per commercial_document deleted' do
        expect do
          delete :destroy_many, params: {
            type: 'Invoice',
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
