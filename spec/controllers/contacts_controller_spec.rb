# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController do
  before(:each) { create_and_login }

  describe 'GET /contacts' do
    context 'with valid information' do
      it 'will render all contacts' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /contacts/:id' do
    context 'with a valid identifier' do
      let(:contact) { current_organization.contacts.create(display_name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: contact.id }

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

  describe 'GET /contacts/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /contacts/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /contacts' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          contact: {
            display_name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new contact' do
        expect do
          post :create, params: {
            contact: {
              display_name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(Contact, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            contact: {
              display_name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          contact: {
            display_name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new contact' do
        expect do
          post :create, params: {
            contact: {
              display_name: ''
            }
          }, format: :html
        end.not_to change(Contact, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            contact: {
              display_name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /contacts/:id/edit' do
    context 'with a valid identifier' do
      let(:contact) { current_organization.contacts.create(display_name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: contact.id }

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

  describe 'PATCH /contacts/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:contact) { current_organization.contacts.create(display_name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: contact.id, contact: { display_name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the contact' do
        contact = current_organization.contacts.create(display_name: 'Default display_name')
        patch :update, params: { id: contact.id, contact: { display_name: 'The Jedis' } }, format: :turbo_stream
        contact.reload

        expect(contact.display_name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: contact.id, contact: {
              display_name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:contact) { current_organization.contacts.create(display_name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: contact.id, contact: { display_name: '' } }

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

  describe 'DELETE /contacts/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        contact = current_organization.contacts.create(display_name: 'Default display_name')

        delete :destroy, params: { id: contact.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the contact' do
        contact = current_organization.contacts.create(display_name: 'Default display_name')

        expect { delete :destroy, params: { id: contact.id }, format: :turbo_stream }.to change(Contact, :count)
      end

      it 'creates an audit event' do
        contact = current_organization.contacts.create(display_name: 'Default display_name')

        expect do
          delete :destroy, params: {
            id: contact.id
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

      it 'does not eletes the contact' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(Contact, :count)
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

  describe 'DELETE /contacts' do
    context 'with valid ids' do
      it 'renders the view' do
        contact_1 = current_organization.contacts.create(display_name: 'Default display_name 1')
        contact_2 = current_organization.contacts.create(display_name: 'Default display_name 2')
        contact_3 = current_organization.contacts.create(display_name: 'Default display_name 3')

        delete :destroy_many, params: {
          item_ids: [contact_1.id, contact_2.id, contact_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the contacts' do
        contact_1 = current_organization.contacts.create(display_name: 'Default display_name 1')
        contact_2 = current_organization.contacts.create(display_name: 'Default display_name 2')
        contact_3 = current_organization.contacts.create(display_name: 'Default display_name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [contact_1.id, contact_2.id, contact_3.id]
          }, format: :turbo_stream
        end.to change(Contact, :count).by(-3)
      end

      it 'creates an audit event per contact deleted' do
        contact_1 = current_organization.contacts.create(display_name: 'Default display_name 1')
        contact_2 = current_organization.contacts.create(display_name: 'Default display_name 2')
        contact_3 = current_organization.contacts.create(display_name: 'Default display_name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [contact_1.id, contact_2.id, contact_3.id]
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

      it 'does not deletes the contacts' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Contact, :count)
      end

      it 'does not creates an audit event per contact deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
