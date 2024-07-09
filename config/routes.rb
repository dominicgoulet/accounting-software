# frozen_string_literal: true

Rails.application.routes.draw do
  mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?

  #
  # API
  #

  constraints subdomain: 'api' do
    scope module: :api do
      namespace :v1 do
        post '/webhooks', to: 'webhooks#create'

        resources :journal_entries, only: %i[index show create update destroy]
        resources :accounts, only: %i[index show create update destroy]
        resources :contacts, only: %i[index show create update destroy]
        resources :items, only: %i[index show create update destroy]
        resources :sales_taxes, only: %i[index show create update destroy]
      end
    end
  end

  #
  # Application
  #

  constraints subdomain: 'app' do
    root 'app#dashboard'

    concern :paginatable do
      get '(page/:page)', action: :index, on: :collection, as: ''
    end

    #
    # Public facing routes (not signed in)
    #

    # Sessions
    get '/sign_in', to: 'sessions#new'
    post '/sign_in', to: 'sessions#create'
    delete '/sign_out', to: 'sessions#destroy'

    # Registrations
    get '/sign_up', to: 'registrations#new'
    post '/sign_up', to: 'registrations#create'

    # Passwords
    get '/forgot_password', to: 'passwords#new'
    post '/forgot_password', to: 'passwords#create'
    get '/passwords/:reset_token', to: 'passwords#edit', as: :reset_password
    patch '/passwords/:reset_token', to: 'passwords#update'

    #
    # Setup (onboarding)
    #

    get '/setup', to: 'setup#new', as: :setup
    patch '/setup', to: 'setup#new'

    get '/setup/about', to: 'setup#about', as: :setup_about
    patch '/setup/about', to: 'setup#about'

    get '/setup/organization', to: 'setup#organization', as: :setup_organization
    patch '/setup/organization', to: 'setup#organization'

    get '/setup/bank', to: 'setup#bank', as: :setup_bank
    patch '/setup/bank', to: 'setup#bank'

    get '/setup/import', to: 'setup#import', as: :setup_import
    post '/setup/import', to: 'setup#import'
    patch '/setup/import', to: 'setup#import'

    get '/setup/account', to: 'setup#account', as: :setup_account
    patch '/setup/account', to: 'setup#account'

    #
    # App
    #
    get '/', to: 'app#dashboard', as: :dashboard
    get '/transactions', to: 'transactions#index', as: :transactions
    get '/contacts', to: 'contacts#index', as: :people
    get '/documents', to: 'app#documents', as: :documents
    get '/launchpad', to: 'app#launchpad', as: :launchpad
    get '/ledger', to: 'app#ledger', as: :ledger
    get '/shoebox', to: 'app#shoebox', as: :shoebox
    get '/auditor', to: 'app#auditor', as: :auditor

    #
    # Commercial Documents
    #

    concern :commercial_documentable do
      resources :payments, controller: 'commercial_document_payments'

      collection do
        get 'archives'
        delete '', to: 'commercial_documents#destroy_many'
      end

      member do
        get 'prepare_email'
        post 'send_email'
        patch 'accept_draft'
        patch 'return_to_draft'
        patch 'mark_as_sent'
        patch 'mark_as_new'
      end
    end

    resources :invoices, controller: 'commercial_documents', type: 'Invoice', concerns: :commercial_documentable
    resources :bills, controller: 'commercial_documents', type: 'Bill', concerns: :commercial_documentable
    resources :deposits, controller: 'commercial_documents', type: 'Deposit', concerns: :commercial_documentable
    resources :expenses, controller: 'commercial_documents', type: 'Expense', concerns: :commercial_documentable
    resources :estimates, controller: 'commercial_documents', type: 'Estimate', concerns: :commercial_documentable
    resources :purchase_orders, controller: 'commercial_documents', type: 'PurchaseOrder',
                                concerns: :commercial_documentable

    #
    # Audit log
    #
    get '/audit_trail/:auditable_type/:auditable_id', to: 'audit_events#index', as: :audit_trail

    #
    # Transactions
    #
    get '/transactions/:bank_account_id', to: 'transactions#index', as: :bank_account_transactions
    get '/transactions/:bank_account_id/all', to: 'transactions#all', as: :all_bank_account_transactions

    #
    # Bank
    #
    post '/banking/create_link_token', to: 'banking#create_link_token'
    post '/banking/update_link_token', to: 'banking#update_link_token'
    post '/banking/exchange_public_token', to: 'banking#exchange_public_token'

    #
    # Bank accounts
    #
    patch '/bank_accounts/fetch_transactions', to: 'bank_accounts#fetch_transactions',
                                               as: :fetch_transactions_bank_accounts

    #
    # Bank transaction rules
    #
    get '/bank_transaction_rules/new(/:bank_transaction_id)', to: 'bank_transaction_rules#new',
                                                              as: :new_bank_transaction_rule
    resources :bank_transaction_rules do
      member do
        patch 'enforce'
      end
    end
    delete '/bank_transaction_rules', to: 'bank_transaction_rules#destroy_many',
                                      as: :destroy_many_bank_transaction_rules

    resources :bank_transaction_rule_matches do
      member do
        patch 'apply'
      end
    end

    #
    # Bank transactions
    #
    resources :bank_transactions do
      # Bank transaction transactionable
      resources :bank_transaction_transactionables, as: :transactionables

      member do
        patch 'reset'
        patch 'approve'
        patch 'reject'
        patch 'review'

        patch 'confirm_invoice_match/:invoice_id', to: 'bank_transactions#confirm_invoice_match',
                                                   as: :confirm_invoice_match
        patch 'confirm_bill_match/:bill_id', to: 'bank_transactions#confirm_bill_match', as: :confirm_bill_match
      end
    end

    #
    # Contacts
    #
    get '/contacts/new/contextual', to: 'contacts#new_contextual', as: :new_contextual_contact
    get '/contacts/customers', to: 'contacts#index', as: :customers_contacts
    get '/contacts/suppliers', to: 'contacts#index', as: :suppliers_contacts
    get '/contacts/employees', to: 'contacts#index', as: :employees_contacts

    resources :contacts, concerns: :paginatable do
      member do
        get 'estimates', to: 'contacts#show', as: :estimates
        get 'invoices', to: 'contacts#show', as: :invoices
        get 'deposits', to: 'contacts#show', as: :deposits
        get 'purchase_orders', to: 'contacts#show', as: :purchase_orders
        get 'bills', to: 'contacts#show', as: :bills
        get 'expenses', to: 'contacts#show', as: :expenses
      end
    end
    delete '/contacts', to: 'contacts#destroy_many', as: :destroy_many_contacts

    #
    # Journal Entries
    #
    get '/journal_entries/integrations/:integration_id(/:journalable_type)', to: 'journal_entries#index',
                                                                             as: :journal_entries_integration
    get '/journal_entries/journalable/:journalable', to: 'journal_entries#index', as: :journal_entries_journalable, constraints: lambda {
 |request| JournalEntry.journalable.include? request.params[:journalable]
                                                                                                                                 }
    resources :journal_entries
    delete '/journal_entries', to: 'journal_entries#destroy_many', as: :destroy_many_journal_entries

    #
    # Transfers
    #
    resources :transfers
    delete '/transfers', to: 'transfers#destroy_many', as: :destroy_many_transfers

    #
    # Settings
    #
    scope 'settings', module: 'settings' do
      get '/', to: 'accounts#index', as: :settings

      #
      # Accounts
      #
      get '/accounts/new/contextual', to: 'accounts#new_contextual', as: :new_contextual_account
      get '/accounts/:classification',
          to: 'accounts#index',
          as: :accounts_classification,
          constraints: lambda { |request|
                         Account.classification.values.include? request.params[:classification]
                       }
      get '/accounts/new/:classification',
          to: 'accounts#new',
          as: :new_account_classification,
          constraints: lambda { |request|
                         Account.classification.values.include? request.params[:classification]
                       }
      resources :accounts, concerns: :paginatable
      delete '/accounts', to: 'accounts#destroy_many', as: :destroy_many_accounts

      #
      # Sales taxes
      #
      get '/sales_taxes/new/contextual', to: 'sales_taxes#new_contextual', as: :new_contextual_sales_tax
      resources :sales_taxes
      delete '/sales_taxes', to: 'sales_taxes#destroy_many', as: :destroy_many_sales_taxes

      #
      # Items
      #
      get '/items/new/contextual', to: 'items#new_contextual', as: :new_contextual_item
      get '/items/:kind',
          to: 'items#index',
          as: :items_kind,
          constraints: lambda { |request|
                         %w[all buy
                            sell].include? request.params[:kind]
                       }
      resources :items
      delete '/items', to: 'items#destroy_many', as: :destroy_many_items

      #
      # Integrations
      #
      get '/integrations/new/contextual', to: 'integrations#new_contextual', as: :new_contextual_integration
      resources :integrations
      delete '/integrations', to: 'integrations#destroy_many', as: :destroy_many_integrations

      #
      # Bank crendetials
      #
      resources :bank_credentials

      #
      # Organizations
      #
      resources :organizations do
        member do
          patch 'sign_in'
          get 'members'
          get 'roles'
          get 'business_units'
          get 'permissions'
        end
      end

      #
      # Users
      #
      resources :users do
        member do
          get 'change_password'
          patch 'cancel_change_email'
        end
      end

      #
      # Memberships
      #
      resources :memberships do
        member do
          patch 'promote'
          patch 'demote'
        end
      end
      delete '/memberships', to: 'memberships#destroy_many', as: :destroy_many_memberships

      #
      # Permissions
      #
      resources :permissions do
        member do
          patch 'permission_level_none'
          patch 'permission_level_view'
          patch 'permission_level_edit'
        end
      end

      #
      # Roles
      #
      get '/roles/new/contextual', to: 'roles#new_contextual', as: :new_contextual_role
      resources :roles
      delete '/roles', to: 'roles#destroy_many', as: :destroy_many_roles

      #
      # Business units
      #
      get '/business_units/new/contextual', to: 'business_units#new_contextual', as: :new_contextual_business_unit
      resources :business_units
      delete '/business_units', to: 'business_units#destroy_many', as: :destroy_many_business_units
    end

    #
    # Reports
    #
    resources :reports do
      collection do
        get 'overview'
        get 'balance_sheet'
        get 'profit_and_loss'
        get 'cashflow'
        get 'account_payable_aging'
        get 'account_receivable_aging'
        get 'sales_tax'
        get 'account/:account_id', to: 'reports#account', as: :account
      end
    end

    #
    # Webhooks
    #
    post '/webhooks/plaid', to: 'webhooks#plaid'
  end
end
