# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::UsersController do
  before(:each) { create_and_login }

  describe 'GET /settings/users/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        get :show, params: { id: current_user.id }

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

  describe 'GET /settings/users/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        get :edit, params: { id: current_user.id }

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

  describe 'GET /settings/users/:id/change_password' do
    context 'with a valid identifier' do
      it 'renders the view' do
        get :change_password, params: { id: current_user.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :change_password, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /settings/users/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      it 'renders the view' do
        patch :update, params: { id: current_user.id, user: { first_name: 'Darth', last_name: 'Vader' } },
                       format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the user' do
        patch :update, params: { id: current_user.id, user: { first_name: 'Darth', last_name: 'Vader' } },
                       format: :turbo_stream
        current_user.reload

        expect(current_user.display_name).to eq('Darth Vader')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: current_user.id,
            user: {
              first_name: 'Darth', last_name: 'Vader'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and valid new email' do
      it 'renders the view' do
        patch :update, params: { id: current_user.id, user: { email: 'darth.vader@theempire.com' } },
                       format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the user' do
        patch :update, params: { id: current_user.id, user: { email: 'darth.vader@theempire.com' } },
                       format: :turbo_stream
        current_user.reload

        expect(current_user.unconfirmed_email).to eq('darth.vader@theempire.com')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: current_user.id,
            user: {
              email: 'darth.vader@theempire.com'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid email' do
      it 'renders the view' do
        patch :update, params: { id: current_user.id, user: { email: 'invalid-email' } }

        expect(response).to have_http_status(422)
      end
    end

    context 'with a valid identifier and invalid current password' do
      it 'renders the view' do
        patch :update, params: { id: current_user.id, user: { password: 'invalid-password' } }

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

  describe 'PATCH /settings/users/:id/cancel_change_email' do
    context 'with a valid identifier' do
      it 'renders the view' do
        patch :cancel_change_email, params: { id: current_user.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :cancel_change_email, params: { id: 'invalid-id' }, format: :turbo_stream

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
