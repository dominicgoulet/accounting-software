# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ContactsController do
  context 'GET /contacts' do
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

      describe 'returns a json of all your contacts' do
        it { expect(json).to have_json_size(1) }
        it { expect(json).to include_json(integration.organization.contacts.first.to_json) }
      end
    end
  end

  context 'POST /contacts' do
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

      describe 'with invalid contact information' do
        before(:each) { post :create }

        it { should respond_with 422 }

        describe 'returns an error' do
          it { expect(json).to have_json_size(1) }
          it { expect(json).to be_json_eql(%({"display_name":["can't be blank"]})) }
        end
      end

      describe 'with valid contact information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { post :create, params: { contact: { display_name: 'Valid name' } } }

        it { should respond_with 201 }

        describe 'adds to the contacts collection' do
          before(:each) { get :index }

          it { should respond_with 200 }

          describe 'GET / returns the new contact' do
            it { expect(integration.organization.contacts.size).to eq(2) }
            it { expect(json).to have_json_size(2) }
            it { expect(json).to include_json(integration.organization.contacts.first.to_json) }
            it { expect(json).to include_json(integration.organization.contacts.last.to_json) }
          end
        end
      end
    end
  end

  context 'GET /contacts/:id' do
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

      describe 'with invalid contact id' do
        before(:each) { get :show, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid contact id ' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { get :show, params: { id: integration.organization.contacts.first.id } }

        it { should respond_with 200 }

        describe 'returns contact information' do
          it { expect(json).to be_json_eql(integration.organization.contacts.first.to_json) }
        end
      end
    end
  end

  context 'PATCH /contacts/:id' do
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

      describe 'with invalid contact id' do
        before(:each) { patch :update, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid contact id and invalid contact information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.contacts.first.id, contact: { display_name: '' } }
        end

        it { should respond_with 422 }
      end

      describe 'with valid contact id and valid contact information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update,
                params: { id: integration.organization.contacts.first.id, contact: { display_name: 'Updated name' } }
        end

        it { should respond_with 204 }
      end
    end
  end

  context 'DELETE /contacts/:id' do
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

      let(:to_be_deleted) { integration.organization.contacts.create(display_name: 'to be deleted') }

      describe 'with invalid contact id' do
        before(:each) { delete :destroy, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid contact id' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 204 }
      end

      describe 'with valid contact id but a contact that cannot be deleted' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { to_be_deleted.organization.invoices.create(date: Date.today, contact: to_be_deleted) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 422 }
      end
    end
  end
end
