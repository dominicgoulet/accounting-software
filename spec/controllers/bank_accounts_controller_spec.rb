# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankAccountsController do
  before(:each) { create_and_login }

  describe 'PATCH /fetch_transactions' do
    context 'with valid information' do
      it 'will render the view' do
        patch :fetch_transactions, format: :turbo_stream

        expect(response).to have_http_status(200)
      end
    end
  end
end
