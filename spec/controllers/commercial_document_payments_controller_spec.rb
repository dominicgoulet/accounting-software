# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommercialDocumentPaymentsController do
  before(:each) { create_and_login }

  describe 'GET /commercial_document/:type/:id/payments/new' do
    let(:contact) { FactoryBot.create(:contact) }
    let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

    context 'with valid parameters' do
      it 'renders the view' do
        get :new, params: { type: 'Invoice', invoice_id: commercial_document.id }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /commercial_document/:type/:id/payments' do
    let(:contact) { FactoryBot.create(:contact) }
    let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          type: 'Invoice',
          invoice_id: commercial_document.id,
          payment: {
            date: Date.today,
            amount: 100,
            account_id: current_organization.accounts.first.id
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new commercial_document' do
        expect do
          post :create, params: {
            type: 'Invoice',
            invoice_id: commercial_document.id,
            payment: {
              date: Date.today,
              amount: 100,
              account_id: current_organization.accounts.first.id
            }
          }, format: :turbo_stream
        end.to change(CommercialDocumentPayment, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            type: 'Invoice',
            invoice_id: commercial_document.id,
            payment: {
              date: Date.today,
              amount: 100,
              account_id: current_organization.accounts.first.id
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          type: 'Invoice',
          invoice_id: commercial_document.id,
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
            invoice_id: commercial_document.id,
            commercial_document: {
              date: ''
            }
          }, format: :html
        end.not_to change(CommercialDocumentPayment, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            type: 'Invoice',
            invoice_id: commercial_document.id,
            commercial_document: {
              date: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /commercial_document/:type/:id/payments/:id/edit' do
    let(:contact) { FactoryBot.create(:contact) }
    let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

    context 'with a valid identifier' do
      let(:commercial_document_payment) do
        commercial_document.payments.create(organization: current_organization, account: current_organization.accounts.first,
                                            date: Date.today, amount: 100)
      end

      it 'renders the view' do
        get :edit, params: { type: 'Invoice', invoice_id: commercial_document.id, id: commercial_document_payment.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :edit, params: { type: 'Invoice', invoice_id: commercial_document.id, id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /commercial_document/:type/:id/payments/:id' do
    let(:contact) { FactoryBot.create(:contact) }
    let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

    context 'with a valid identifier and valid parameters' do
      let(:commercial_document_payment) do
        commercial_document.payments.create(organization: current_organization, account: current_organization.accounts.first,
                                            date: Date.today, amount: 100)
      end

      it 'renders the view' do
        patch :update, params: {
          type: 'Invoice',
          invoice_id: commercial_document.id,
          id: commercial_document_payment.id,
          payment: {
            date: Date.today - 1
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the commercial_document_payment' do
        patch :update, params: {
          type: 'Invoice',
          invoice_id: commercial_document.id,
          id: commercial_document_payment.id,
          payment: {
            date: Date.today - 1
          }
        }, format: :turbo_stream

        commercial_document_payment.reload

        expect(commercial_document_payment.date).to eq(Date.today - 1)
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            type: 'Invoice',
            invoice_id: commercial_document.id,
            id: commercial_document_payment.id,
            payment: {
              date: Date.today - 1
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:commercial_document_payment) do
        commercial_document.payments.create(organization: current_organization, account: current_organization.accounts.first,
                                            date: Date.today, amount: 100)
      end

      it 'renders the view' do
        patch :update, params: {
          type: 'Invoice',
          invoice_id: commercial_document.id,
          id: commercial_document_payment.id,
          payment: {
            date: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :update, params: { type: 'Invoice', invoice_id: commercial_document.id, id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /commercial_document/:type/:id/payments/:id' do
    let(:contact) { FactoryBot.create(:contact) }
    let(:commercial_document) { current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice') }

    context 'with a valid identifier' do
      it 'renders the view' do
        commercial_document_payment = commercial_document.payments.create(organization: current_organization,
                                                                          account: current_organization.accounts.first, date: Date.today, amount: 100)

        delete :destroy,
               params: { type: 'Invoice', invoice_id: commercial_document.id, id: commercial_document_payment.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the commercial_document' do
        commercial_document_payment = commercial_document.payments.create(organization: current_organization,
                                                                          account: current_organization.accounts.first, date: Date.today, amount: 100)

        expect do
          delete :destroy, params: { type: 'Invoice', invoice_id: commercial_document.id, id: commercial_document_payment.id },
                           format: :turbo_stream
        end.to change(CommercialDocumentPayment, :count)
      end

      it 'creates an audit event' do
        commercial_document_payment = commercial_document.payments.create(organization: current_organization,
                                                                          account: current_organization.accounts.first, date: Date.today, amount: 100)

        expect do
          delete :destroy,
                 params: { type: 'Invoice', invoice_id: commercial_document.id, id: commercial_document_payment.id }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { type: 'Invoice', invoice_id: commercial_document.id, id: 'invalid-id' },
                         format: :turbo_stream

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the commercial_document' do
        expect do
          delete :destroy, params: { type: 'Invoice', invoice_id: commercial_document.id, id: 'invalid-id' },
                           format: :turbo_stream
        end.not_to change(CommercialDocumentPayment, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: { type: 'Invoice', invoice_id: commercial_document.id, id: 'invalid-id' },
                           format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
