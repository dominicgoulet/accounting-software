# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppController do
  before(:each) { create_and_login }

  describe 'GET /' do
    context 'with valid information' do
      it 'will render a dashboard' do
        get :dashboard

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /transactions' do
    context 'with valid information' do
      it 'will render the transactions' do
        get :transactions

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /documents' do
    context 'with valid information' do
      it 'will render the documents' do
        get :documents

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /launchpad' do
    context 'with valid information' do
      it 'will render the launchpad' do
        get :launchpad

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /ledger' do
    context 'with valid information' do
      it 'will render the ledger' do
        get :ledger

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /shoebox' do
    context 'with valid information' do
      it 'will render the shoebox' do
        get :shoebox

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /auditor' do
    context 'with valid information' do
      it 'will render the auditor' do
        get :auditor

        expect(response).to have_http_status(200)
      end
    end
  end
end
