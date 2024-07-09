# frozen_string_literal: true

class BankTransactionCrawler
  # Find matches across all rules for an organization
  def self.execute(organization)
    organization.bank_credentials.each do |cred|
      fetch_transactions(cred)
    end
  end

  def self.fetch_transactions(bank_credential)
    bank_credential.bank_accounts.each do |bank_account|
      bank_account.update(status: :updating)
    end

    # Update account balances
    accounts, get_accounts_success = Banking.get_accounts(bank_credential)

    if get_accounts_success
      accounts.each do |account|
        bank_credential.bank_accounts
                       .find_or_create_by(account_id: account.account_id)
                       .update(
                         available_balance: (account.balances.available || 0),
                         current_balance: (account.balances.current || 0),
                         limit: (account.balances.limit || 0),
                         iso_currency_code: account.balances.iso_currency_code,
                         unofficial_currency_code: account.balances.unofficial_currency_code,
                         mask: account.mask,
                         name: account.name,
                         official_name: account.official_name,
                         account_type: account.type,
                         account_subtype: account.subtype
                       )
      end
    end

    added, _modified, _removed, cursor, get_transactions_success = Banking.get_transactions(bank_credential)

    if get_transactions_success
      added.each do |transaction_data|
        bank_credential.bank_accounts
                       .find_by(
                         account_id: transaction_data.account_id
                       )
                       .bank_transactions
                       .find_or_create_by(
                         account_id: transaction_data.account_id,
                         transaction_id: transaction_data.transaction_id
                       )
                       .update(
                         category_id: transaction_data.category_id,
                         payment_channel: transaction_data.payment_channel,
                         name: transaction_data.name,
                         merchant_name: transaction_data.merchant_name,
                         amount: transaction_data.amount,
                         debit: transaction_data.amount.negative? ? transaction_data.amount.abs : 0,
                         credit: transaction_data.amount >= 0 ? transaction_data.amount : 0,
                         iso_currency_code: transaction_data.iso_currency_code,
                         unofficial_currency_code: transaction_data.unofficial_currency_code,
                         date: transaction_data.date,
                         datetime: transaction_data.datetime,
                         authorized_date: transaction_data.authorized_date,
                         authorized_datetime: transaction_data.authorized_datetime,
                         pending: transaction_data.pending,
                         check_number: transaction_data.check_number,
                         transaction_code: transaction_data.transaction_code
                       )
      end
    end

    if get_accounts_success && get_transactions_success
      bank_credential.bank_accounts.each do |bank_account|
        bank_account.update(status: :up_to_date)
      end
    end

    bank_credential.update(
      latest_cursor: cursor,
      last_sync_at: Time.zone.now
    )
  end
end
