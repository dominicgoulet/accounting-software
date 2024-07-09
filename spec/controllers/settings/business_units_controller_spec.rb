# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::BusinessUnitsController do
  before(:each) { create_and_login }

  describe 'GET /settings/business_units' do
    context 'with valid information' do
      it 'will render all business_units' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/business_units/:id' do
    context 'with a valid identifier' do
      let(:business_unit) { current_organization.business_units.create(name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: business_unit.id }

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

  describe 'GET /settings/business_units/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/business_units/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/business_units' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          business_unit: {
            name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new business_unit' do
        expect do
          post :create, params: {
            business_unit: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(BusinessUnit, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            business_unit: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          business_unit: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new business_unit' do
        expect do
          post :create, params: {
            business_unit: {
              name: ''
            }
          }, format: :html
        end.not_to change(BusinessUnit, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            business_unit: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/business_units/:id/edit' do
    context 'with a valid identifier' do
      let(:business_unit) { current_organization.business_units.create(name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: business_unit.id }

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

  describe 'PATCH /settings/business_units/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:business_unit) { current_organization.business_units.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: business_unit.id, business_unit: { name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the business_unit' do
        business_unit = current_organization.business_units.create(name: 'Default name')
        patch :update, params: { id: business_unit.id, business_unit: { name: 'The Jedis' } }, format: :turbo_stream
        business_unit.reload

        expect(business_unit.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: business_unit.id, business_unit: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:business_unit) { current_organization.business_units.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: business_unit.id, business_unit: { name: '' } }

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

  describe 'DELETE /settings/business_units/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        business_unit = current_organization.business_units.create(name: 'Default name')

        delete :destroy, params: { id: business_unit.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the business_unit' do
        business_unit = current_organization.business_units.create(name: 'Default name')

        expect do
          delete :destroy, params: { id: business_unit.id }, format: :turbo_stream
        end.to change(BusinessUnit, :count)
      end

      it 'creates an audit event' do
        business_unit = current_organization.business_units.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: business_unit.id
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

      it 'does not eletes the business_unit' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(BusinessUnit, :count)
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

  describe 'DELETE /settings/business_units' do
    context 'with valid ids' do
      it 'renders the view' do
        business_unit_1 = current_organization.business_units.create(name: 'Default name 1')
        business_unit_2 = current_organization.business_units.create(name: 'Default name 2')
        business_unit_3 = current_organization.business_units.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [business_unit_1.id, business_unit_2.id, business_unit_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the business_units' do
        business_unit_1 = current_organization.business_units.create(name: 'Default name 1')
        business_unit_2 = current_organization.business_units.create(name: 'Default name 2')
        business_unit_3 = current_organization.business_units.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [business_unit_1.id, business_unit_2.id, business_unit_3.id]
          }, format: :turbo_stream
        end.to change(BusinessUnit, :count).by(-3)
      end

      it 'creates an audit event per business_unit deleted' do
        business_unit_1 = current_organization.business_units.create(name: 'Default name 1')
        business_unit_2 = current_organization.business_units.create(name: 'Default name 2')
        business_unit_3 = current_organization.business_units.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [business_unit_1.id, business_unit_2.id, business_unit_3.id]
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

      it 'does not deletes the business_units' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(BusinessUnit, :count)
      end

      it 'does not creates an audit event per business_unit deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
