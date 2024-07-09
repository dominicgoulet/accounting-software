# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SalesTaxesController do
  context 'GET /sales_taxes' do
    describe 'without autorization token' do
      before(:each) { get :index }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
      before(:each) { authenticate(integration) }
      before(:each) { get :index }

      it { should respond_with 200 }

      describe 'returns a json of all your sales_taxes' do
        it { expect(json).to have_json_size(1) }
        it { expect(json).to include_json(integration.organization.sales_taxes.first.to_json) }
      end
    end
  end

  context 'POST /sales_taxes' do
    describe 'without autorization token' do
      before(:each) { post :create }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
      before(:each) { authenticate(integration) }

      describe 'with invalid sales_tax information' do
        before(:each) { post :create }

        it { should respond_with 422 }

        describe 'returns an error' do
          it { expect(json).to have_json_size(2) }
          it { expect(json).to be_json_eql(%({"name":["can't be blank"],"rate":["can't be blank"]})) }
        end
      end

      describe 'with valid sales_tax information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { authenticate(integration) }
        before(:each) { post :create, params: { sales_tax: { name: 'Valid name', rate: 5 } } }

        it { should respond_with 201 }

        describe 'adds to the sales_taxes collection' do
          before(:each) { get :index }

          it { should respond_with 200 }

          describe 'GET / returns the new sales_tax' do
            it { expect(integration.organization.sales_taxes.size).to eq(2) }
            it { expect(json).to have_json_size(2) }
            it { expect(json).to include_json(integration.organization.sales_taxes.first.to_json) }
            it { expect(json).to include_json(integration.organization.sales_taxes.last.to_json) }
          end
        end
      end
    end
  end

  context 'GET /sales_taxes/:id' do
    describe 'without autorization token' do
      before(:each) { get :show, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
      before(:each) { authenticate(integration) }

      describe 'with invalid sales_tax id' do
        before(:each) { get :show, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid sales_tax id ' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
        before(:each) { authenticate(integration) }
        before(:each) { get :show, params: { id: integration.organization.sales_taxes.first.id } }

        it { should respond_with 200 }

        describe 'returns sales_tax information' do
          it { expect(json).to be_json_eql(integration.organization.sales_taxes.first.to_json) }
        end
      end
    end
  end

  context 'PATCH /sales_taxes/:id' do
    describe 'without autorization token' do
      before(:each) { patch :update, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
      before(:each) { authenticate(integration) }

      describe 'with invalid sales_tax id' do
        before(:each) { patch :update, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid sales_tax id and invalid sales_tax information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update, params: { id: integration.organization.sales_taxes.first.id, sales_tax: { name: '' } }
        end

        it { should respond_with 422 }
      end

      describe 'with valid sales_tax id and valid sales_tax information' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
        before(:each) { authenticate(integration) }
        before(:each) do
          patch :update,
                params: { id: integration.organization.sales_taxes.first.id, sales_tax: { name: 'Updated name' } }
        end

        it { should respond_with 204 }
      end
    end
  end

  context 'DELETE /sales_taxes/:id' do
    describe 'without autorization token' do
      before(:each) { delete :destroy, params: { id: 'id' } }

      it { should respond_with 401 }

      describe 'returns an error' do
        it { expect(json).to be_json_eql(json_error_not_authorized) }
      end
    end

    describe 'with a valid authorization token' do
      let(:integration) { FactoryBot.create(:integration) }
      before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
      before(:each) { authenticate(integration) }

      let(:to_be_deleted) { integration.organization.sales_taxes.create(name: 'to be deleted', rate: 5) }

      describe 'with invalid sales_tax id' do
        before(:each) { delete :destroy, params: { id: 'invalid-id' } }

        it { should respond_with 404 }

        describe 'returns an error' do
          it { expect(json).to be_json_eql(json_error_not_found) }
        end
      end

      describe 'with valid sales_tax id' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
        before(:each) { authenticate(integration) }
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 204 }
      end

      describe 'with valid sales_tax id but a sales_tax that cannot be deleted' do
        let(:integration) { FactoryBot.create(:integration) }
        before(:each) { integration.organization.sales_taxes.create(name: 'My sales_tax', rate: 5) }
        before(:each) { authenticate(integration) }
        before(:each) do
          journal_entry = integration.organization.journal_entries.create(integration:, date: Date.today)
          journal_entry.journal_entry_lines.create(account: to_be_deleted.account)
        end
        before(:each) { delete :destroy, params: { id: to_be_deleted.id } }

        it { should respond_with 422 }
      end
    end
  end
end
