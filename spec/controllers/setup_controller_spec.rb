# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetupController do
  before(:each) { create_and_login }

  describe 'GET /setup' do
    context 'with valid information' do
      it 'will render view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /setup/about' do
    context 'with valid information' do
      it 'will render view' do
        get :about

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /setup/organization' do
    context 'with valid information' do
      it 'will render view' do
        get :organization

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /setup/bank' do
    context 'with valid information' do
      it 'will render view' do
        get :bank

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /setup/import' do
    context 'with valid information' do
      it 'will render view' do
        get :import

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /setup/account' do
    context 'with valid information' do
      it 'will render view' do
        get :account

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'PATCH /setup' do
    context 'with valid information' do
      it 'will render view' do
        patch :new

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_about_path)
      end
    end
  end

  describe 'PATCH /setup/about' do
    context 'with valid information' do
      it 'will render view' do
        patch :about, params: { user: { first_name: 'Darth', last_name: 'Vader' } }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_organization_path)
      end
    end

    context 'with no information' do
      it 'will render view' do
        patch :about

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /setup/organization' do
    context 'with valid information' do
      it 'will render view' do
        patch :organization, params: { organization: { name: 'The Empire', website: 'theempire.com' } }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_bank_path)
      end
    end

    context 'with invalid information' do
      it 'will render view' do
        patch :organization, params: { organization: { name: '' } }

        expect(response).to have_http_status(422)
      end
    end

    context 'with no information' do
      it 'will render view' do
        patch :organization

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /setup/bank' do
    context 'with valid information' do
      it 'will render view' do
        patch :bank

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_import_path)
      end
    end
  end

  describe 'PATCH /setup/import' do
    context 'with valid information' do
      it 'will render view' do
        patch :import

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(setup_account_path)
      end
    end
  end

  describe 'PATCH /setup/account' do
    context 'with valid information' do
      it 'will render view' do
        patch :account

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
