# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccountsController do
  context 'GET /accounts' do
    describe 'without autorization token' do
      before(:each) { get :index }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { authenticate(integration) }
      before(:each) { get :index }

      it { should respond_with 200 }

      describe 'returns a json of all your accounts' do
        it { expect(json).to have_json_size(9) }
        it { expect(json).to include_json(integration.organization.accounts.first.to_json) }
      end
    end
  end

  context 'POST /accounts' do
    describe 'without autorization token' do
      before(:each) { post :create }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid account information' do
        before(:each) { post :create }

        it { should respond_with 422 }

        describe 'returns an error' do
          it { expect(json).to have_json_size(1) }
          it { expect(json).to be_json_eql(%({"name":["can't be blank"]})) }
        end
      end

      describe 'with valid account information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { post :create, params: { account: { name: 'Valid name' } } }

        it { should respond_with 201 }

        describe 'adds to the accounts collection' do
          before(:each) { get :index }

          it { should respond_with 200 }

          describe 'GET / returns the new account' do
            it { expect(integration.organization.accounts.size).to eq(10) }
            it { expect(json).to have_json_size(10) }
            it { expect(json).to include_json(integration.organization.accounts.first.to_json) }
            it { expect(json).to include_json(integration.organization.accounts.last.to_json) }
          end
        end
      end
    end
  end

  context 'GET /accounts/:id' do
    describe 'without autorization token' do
      before(:each) { get :show, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid account id' do
        before(:each) { get :show, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid account id ' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { get :show, params: { id: integration.organization.accounts.first.id } }

        it { should respond_with 200 }

        describe 'returns account information' do
          it { expect(json).to be_json_eql(integration.organization.accounts.first.to_json) }
        end
      end
    end
  end

  context 'PATCH /accounts/:id' do
    describe 'without autorization token' do
      before(:each) { patch :update, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid account id' do
        before(:each) { patch :update, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid account id and invalid account information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.accounts.first.id, account: { name: '' } }
        end

        it { should respond_with 422 }
      end

      describe 'with valid account id and valid account information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.accounts.first.id, account: { name: 'Updated name' } }
        end

        it { should respond_with 204 }
      end
    end
  end

  context 'DELETE /accounts/:id' do
    describe 'without autorization token' do
      before(:each) { delete :destroy, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { authenticate(integration) }

      let(:to_be_deleted) { integration.organization.accounts.create(name: 'to be deleted') }
      let(:cannot_be_deleted) { integration.organization.accounts.where(system: true).first }

      describe 'with invalid account id' do
        before(:each) { delete :destroy, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid account id' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 204 }
      end

      describe 'with valid account id but an account that cannot be destroyed' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: cannot_be_deleted.id } }

        it { should respond_with 422 }
      end
    end
  end
end
