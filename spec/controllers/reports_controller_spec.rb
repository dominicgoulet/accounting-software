# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportsController do
  before(:each) { create_and_login }

  describe 'GET /' do
    context 'with valid information' do
      it 'will redirect to overview' do
        get :index

        expect(response).to have_http_status(302)
        # FIXME : When overview is available
        # expect(response).to redirect_to overview_reports_path
        expect(response).to redirect_to balance_sheet_reports_path
      end
    end
  end

  describe 'GET /overview' do
    context 'with valid information' do
      it 'will render the overview' do
        get :overview

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /balance_sheet' do
    context 'with valid information' do
      it 'will render the balance_sheet' do
        get :balance_sheet

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /profit_and_loss' do
    context 'with valid information' do
      it 'will render the profit_and_loss' do
        get :profit_and_loss

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /cashflow' do
    context 'with valid information' do
      it 'will render the cashflow' do
        get :cashflow

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /account_payable_aging' do
    context 'with valid information' do
      it 'will render the account_payable_aging' do
        get :account_payable_aging

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /account_receivable_aging' do
    context 'with valid information' do
      it 'will render the account_receivable_aging' do
        get :account_receivable_aging

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /sales_tax' do
    context 'with valid information' do
      it 'will render the sales_tax' do
        get :sales_tax

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /account' do
    context 'with valid information' do
      it 'will render the account' do
        get :account, params: { parent_report: 'balance_sheet', account_id: current_organization.accounts.first.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid information' do
      it 'will render the account' do
        get :account, params: { parent_report: 'balance_sheet', account_id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
