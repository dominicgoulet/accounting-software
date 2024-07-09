# frozen_string_literal: true

class Banking
  require 'plaid'
  require 'json'

  # Plaid client with all the required configurations
  def self.client
    configuration = Plaid::Configuration.new
    configuration.server_index = Plaid::Configuration::Environment[ENV['PLAID_ENVIRONMENT']]
    configuration.api_key['PLAID-CLIENT-ID'] = ENV['PLAID_CLIENT_ID']
    configuration.api_key['PLAID-SECRET'] = ENV['PLAID_SECRET']

    api_client = Plaid::ApiClient.new(configuration)
    Plaid::PlaidApi.new(api_client)
  end

  # Get a link token for the Link web app
  def self.get_link_token(organization_id)
    link_token_create_request = Plaid::LinkTokenCreateRequest.new({
                                                                    user: {
                                                                      client_user_id: organization_id.to_s
                                                                    },
                                                                    client_name: 'Influence Accounting',
                                                                    products: %w[transactions],
                                                                    country_codes: ['CA'],
                                                                    language: 'en',
                                                                    webhook: 'https://ninetyfour-plaid.ultrahook.com/webhooks/plaid',
                                                                    account_filters: {
                                                                      depository: {
                                                                        account_subtypes: ['all']
                                                                      },
                                                                      credit: {
                                                                        account_subtypes: ['all']
                                                                      },
                                                                      loan: {
                                                                        account_subtypes: ['all']
                                                                      }
                                                                    }
                                                                  })

    link_token_response = client.link_token_create(
      link_token_create_request
    )

    link_token_response.link_token
  end

  def self.update_link_token(organization_id, access_token)
    link_token_create_request = Plaid::LinkTokenCreateRequest.new({
                                                                    user: {
                                                                      client_user_id: organization_id.to_s
                                                                    },
                                                                    client_name: 'Influence Accounting',
                                                                    products: %w[transactions],
                                                                    country_codes: ['CA'],
                                                                    language: 'en',
                                                                    webhook: 'https://ninetyfour-plaid.ultrahook.com/webhooks/plaid',
                                                                    account_filters: {
                                                                      depository: {
                                                                        account_subtypes: ['all']
                                                                      },
                                                                      credit: {
                                                                        account_subtypes: ['all']
                                                                      },
                                                                      loan: {
                                                                        account_subtypes: ['all']
                                                                      }
                                                                    },
                                                                    link_customization_name: 'account_selection_v2_custom',
                                                                    update: {
                                                                      account_selection_enabled: true
                                                                    },
                                                                    access_token:
                                                                  })

    link_token_response = client.link_token_create(
      link_token_create_request
    )

    link_token_response.link_token
  end

  # Using a Link token from the webapp, get an access token used to query
  # the plaid API.
  def self.get_access_token(public_token)
    request = Plaid::ItemPublicTokenExchangeRequest.new
    request.public_token = public_token

    response = client.item_public_token_exchange(request)
    response.access_token
  end

  # query the plaid api for all accounts linked (information only, you can't change
  # anything, it is set between the end user and plaid)
  def self.get_institution(access_token)
    request = Plaid::AuthGetRequest.new
    request.access_token = access_token

    response = client.accounts_get(request)
    institution_id = response.item.institution_id

    request2 = Plaid::InstitutionsGetByIdRequest.new(
      {
        institution_id:,
        country_codes: ['CA'],
        options: {
          include_optional_metadata: true
        }
      }
    )

    response2 = client.institutions_get_by_id(request2)
    response2.institution
  end

  # query the plaid api for all accounts linked (information only, you can't change
  # anything, it is set between the end user and plaid)
  def self.get_accounts(bank_credential)
    accounts = []
    request = Plaid::AuthGetRequest.new
    request.access_token = bank_credential.access_token
    success = true

    begin
      response = client.accounts_get(request)
      accounts = response.accounts
    rescue Plaid::ApiError => e
      # Update the credential status
      err = JSON.parse(e.response_body)

      success = false

      bank_credential.update(
        status: 'error',
        error_type: err['error_type'],
        error_code: err['error_code']
      )
    end

    [accounts, success]
  end

  # query the plaid api and get all transactions between two dates.
  def self.get_transactions(bank_credential)
    cursor = bank_credential.latest_cursor

    added = []
    modified = []
    removed = [] # Removed transaction ids
    has_more = true
    success = true

    begin
      # Iterate through each page of new transaction updates for item
      while has_more
        request = Plaid::TransactionsSyncRequest.new(
          {
            access_token: bank_credential.access_token,
            cursor:
          }
        )
        response = client.transactions_sync(request)

        # Add this page of results
        added += response.added
        modified += response.modified
        removed += response.removed
        has_more = response.has_more

        # Update cursor to the next cursor
        cursor = response.next_cursor
      end
    rescue Plaid::ApiError => e
      # Update the credential status
      err = JSON.parse(e.response_body)

      success = false

      bank_credential.update(
        status: 'error',
        error_type: err['error_type'],
        error_code: err['error_code']
      )
    end

    [added, modified, removed, cursor, success]
  end
end
