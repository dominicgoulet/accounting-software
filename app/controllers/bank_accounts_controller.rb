# frozen_string_literal: true

class BankAccountsController < ApplicationController
  def fetch_transactions
    BankTransactionCrawler.execute(current_organization)
    BankTransactionMatcher.execute(current_organization)

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = 'Fetching new transactions.'
        render partial: 'partials/flash'
      end
    end
  end
end
