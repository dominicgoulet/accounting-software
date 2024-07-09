# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ItemsController do
  context 'GET /items' do
    describe 'without autorization token' do
      before(:each) { get :index }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.items.create(name: 'My item') }
      before(:each) { authenticate(integration) }
      before(:each) { get :index }

      it { should respond_with 200 }

      describe 'returns a json of all your items' do
        it { expect(json).to have_json_size(1) }
        it { expect(json).to include_json(integration.organization.items.first.to_json) }
      end
    end
  end

  context 'POST /items' do
    describe 'without autorization token' do
      before(:each) { post :create }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.items.create(name: 'My item') }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid item information' do
        before(:each) { post :create }

        it { should respond_with 422 }

        describe 'returns an error' do
          it { expect(json).to have_json_size(1) }
          it { expect(json).to be_json_eql(%({"name":["can't be blank"]})) }
        end
      end

      describe 'with valid item information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { post :create, params: { item: { name: 'Valid name' } } }

        it { should respond_with 201 }

        describe 'adds to the items collection' do
          before(:each) { get :index }

          it { should respond_with 200 }

          describe 'GET / returns the new item' do
            it { expect(integration.organization.items.size).to eq(2) }
            it { expect(json).to have_json_size(2) }
            it { expect(json).to include_json(integration.organization.items.first.to_json) }
            it { expect(json).to include_json(integration.organization.items.last.to_json) }
          end
        end
      end
    end
  end

  context 'GET /items/:id' do
    describe 'without autorization token' do
      before(:each) { get :show, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.items.create(name: 'My item') }
      before(:each) { authenticate(integration) }

      describe 'with invalid item id' do
        before(:each) { get :show, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid item id ' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.items.create(name: 'My item') }
        before(:each) { authenticate(integration) }
        before(:each) { get :show, params: { id: integration.organization.items.first.id } }

        it { should respond_with 200 }

        describe 'returns item information' do
          it { expect(json).to be_json_eql(integration.organization.items.first.to_json) }
        end
      end
    end
  end

  context 'PATCH /items/:id' do
    describe 'without autorization token' do
      before(:each) { patch :update, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.items.create(name: 'My item') }
      before(:each) { authenticate(integration) }
      before(:each) { authenticate(integration) }

      describe 'with invalid item id' do
        before(:each) { patch :update, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid item id and invalid item information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.items.create(name: 'My item') }
        before(:each) { authenticate(integration) }
        before(:each) { patch :update, params: { id: integration.organization.items.first.id, item: { name: '' } } }

        it { should respond_with 422 }
      end

      describe 'with valid item id and valid item information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.items.create(name: 'My item') }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.items.first.id, item: { name: 'Updated name' } }
        end

        it { should respond_with 204 }
      end
    end
  end

  context 'DELETE /items/:id' do
    describe 'without autorization token' do
      before(:each) { delete :destroy, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.items.create(name: 'My item') }
      before(:each) { authenticate(integration) }

      let(:to_be_deleted) { integration.organization.items.create(name: 'to be deleted') }

      describe 'with invalid item id' do
        before(:each) { delete :destroy, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid item id' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.items.create(name: 'My item') }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 204 }
      end

      describe 'with valid item id but an item that cannot be deleted' do
        let(:integration) { FactoryBot.create(:integration) }
        let(:contact) { FactoryBot.create(:contact) }
        before(:each) { integration.organization.items.create(name: 'My item') }
        before(:each) { authenticate(integration) }
        before(:each) do
          inv = to_be_deleted.organization.invoices.create(contact:, date: Date.today)
          inv.lines.create(account: to_be_deleted.organization.accounts.first, item: to_be_deleted)
        end
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 422 }
      end
    end
  end
end
