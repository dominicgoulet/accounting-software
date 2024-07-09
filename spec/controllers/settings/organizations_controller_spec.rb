# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::OrganizationsController do
  before(:each) { create_and_login }

  describe 'GET /settings/organizations' do
    context 'with valid information' do
      it 'will render all organizations' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/organizations/:id' do
    context 'with a valid identifier' do
      let(:organization) { current_user.organizations.create(name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: organization.id }

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

  describe 'GET /settings/organizations/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/organizations' do
    context 'with valid parameters' do
      it 'redirects to the new organization setup path' do
        post :create, params: {
          organization: {
            name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_path)
      end

      it 'creates a new organization' do
        expect do
          post :create, params: {
            organization: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(Organization, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            organization: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          organization: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new organization' do
        expect do
          post :create, params: {
            organization: {
              name: ''
            }
          }, format: :html
        end.not_to change(Organization, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            organization: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/organizations/:id/edit' do
    context 'with a valid identifier' do
      let(:organization) { current_user.organizations.create(name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: organization.id }

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

  describe 'PATCH /settings/organizations/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:organization) { current_user.organizations.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: organization.id, organization: { name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the organization' do
        organization = current_user.organizations.create(name: 'Default name')
        patch :update, params: { id: organization.id, organization: { name: 'The Jedis' } }, format: :turbo_stream
        organization.reload

        expect(organization.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: organization.id, organization: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:organization) { current_user.organizations.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: organization.id, organization: { name: '' } }

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

  describe 'DELETE /settings/organizations/:id/edit' do
    context 'with a valid identifier and an organization that cannnot be deleted' do
      it 'renders the view' do
        organization = current_user.organizations.create(name: 'Default name')

        delete :destroy, params: { id: organization.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the organization' do
        organization = current_user.organizations.create(name: 'Default name')

        expect do
          delete :destroy, params: { id: organization.id }, format: :turbo_stream
        end.not_to change(Organization, :count)
      end

      it 'does not creates an audit event' do
        organization = current_user.organizations.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: organization.id
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the organization' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(Organization, :count)
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
end
