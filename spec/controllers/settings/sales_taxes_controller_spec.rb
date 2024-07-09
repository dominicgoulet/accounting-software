# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::SalesTaxesController do
  before(:each) { create_and_login }

  describe 'GET /settings/sales_taxes' do
    context 'with valid information' do
      it 'will render all sales_taxes' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/sales_taxes/:id' do
    context 'with a valid identifier' do
      let(:sales_tax) { current_organization.sales_taxes.create(name: 'Default', rate: 5) }

      it 'renders the view' do
        get :show, params: { id: sales_tax.id }

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

  describe 'GET /settings/sales_taxes/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/sales_taxes/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/sales_taxes' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          sales_tax: {
            name: 'The Jedis',
            rate: 5
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new sales_tax' do
        expect do
          post :create, params: {
            sales_tax: {
              name: 'The Jedis',
              rate: 5
            }
          }, format: :turbo_stream
        end.to change(SalesTax, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            sales_tax: {
              name: 'The Jedis',
              rate: 5
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          sales_tax: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new sales_tax' do
        expect do
          post :create, params: {
            sales_tax: {
              name: ''
            }
          }, format: :html
        end.not_to change(SalesTax, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            sales_tax: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/sales_taxes/:id/edit' do
    context 'with a valid identifier' do
      let(:sales_tax) { current_organization.sales_taxes.create(name: 'Default', rate: 5) }

      it 'renders the view' do
        get :edit, params: { id: sales_tax.id }

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

  describe 'PATCH /settings/sales_taxes/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:sales_tax) { current_organization.sales_taxes.create(name: 'Default', rate: 5) }

      it 'renders the view' do
        patch :update, params: { id: sales_tax.id, sales_tax: { name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the sales_tax' do
        sales_tax = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        patch :update, params: { id: sales_tax.id, sales_tax: { name: 'The Jedis' } }, format: :turbo_stream
        sales_tax.reload

        expect(sales_tax.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: sales_tax.id, sales_tax: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:sales_tax) { current_organization.sales_taxes.create(name: 'Default', rate: 5) }

      it 'renders the view' do
        patch :update, params: { id: sales_tax.id, sales_tax: { name: '' } }

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

  describe 'DELETE /settings/sales_taxes/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        sales_tax = current_organization.sales_taxes.create(name: 'Default name', rate: 5)

        delete :destroy, params: { id: sales_tax.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the sales_tax' do
        sales_tax = current_organization.sales_taxes.create(name: 'Default name', rate: 5)

        expect { delete :destroy, params: { id: sales_tax.id }, format: :turbo_stream }.to change(SalesTax, :count)
      end

      it 'creates an audit event' do
        sales_tax = current_organization.sales_taxes.create(name: 'Default name', rate: 5)

        expect do
          delete :destroy, params: {
            id: sales_tax.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier but an sales_tax that cannot be deleted' do
      let(:sales_tax) { current_organization.sales_taxes.create(name: 'Default name', rate: 5) }
      before(:each) do
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax.account)
      end

      it 'renders the view' do
        delete :destroy, params: { id: sales_tax.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not delete the sales_tax' do
        expect { delete :destroy, params: { id: sales_tax.id }, format: :turbo_stream }.not_to change(Item, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: sales_tax.id
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the sales_tax' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(SalesTax, :count)
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

  describe 'DELETE /settings/sales_taxes' do
    context 'with valid ids' do
      it 'renders the view' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name 1', rate: 5)
        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name 2', rate: 5)
        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name 3', rate: 5)

        delete :destroy_many, params: {
          item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the sales_taxes' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name 1', rate: 5)
        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name 2', rate: 5)
        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name 3', rate: 5)

        expect do
          delete :destroy_many, params: {
            item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
          }, format: :turbo_stream
        end.to change(SalesTax, :count).by(-3)
      end

      it 'creates an audit event per sales_tax deleted' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name 1', rate: 5)
        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name 2', rate: 5)
        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name 3', rate: 5)

        expect do
          delete :destroy_many, params: {
            item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
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

      it 'does not deletes the sales_taxes' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(SalesTax, :count)
      end

      it 'does not creates an audit event per sales_tax deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with items that cannot be deleted' do
      it 'renders the view' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_1.account)

        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_2.account)

        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_3.account)

        delete :destroy_many, params: {
          item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the sales_taxes' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_1.account)

        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_2.account)

        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_3.account)

        expect do
          delete :destroy_many, params: {
            item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
          }, format: :turbo_stream
        end.not_to change(Item, :count)
      end

      it 'does not creates an audit event per sales_tax deleted' do
        sales_tax_1 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_1.account)

        sales_tax_2 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_2.account)

        sales_tax_3 = current_organization.sales_taxes.create(name: 'Default name', rate: 5)
        je = current_organization.journal_entries.create(integration: current_organization.integrations.first,
                                                         date: Date.today)
        je.journal_entry_lines.create(account: sales_tax_3.account)

        expect do
          delete :destroy_many, params: {
            item_ids: [sales_tax_1.id, sales_tax_2.id, sales_tax_3.id]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
