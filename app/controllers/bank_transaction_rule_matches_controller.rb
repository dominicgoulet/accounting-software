# frozen_string_literal: true

class BankTransactionRuleMatchesController < ApplicationController
  before_action :bank_transaction_rule_match, only: %i[apply destroy]

  def apply
    if BankTransactionMatcher.apply(bank_transaction_rule_match)
      respond_to do |format|
        flash.now.notice = 'Rule applied.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    else
      respond_to do |format|
        flash.now.notice = 'Rule not applied.'
        format.turbo_stream { render partial: 'partials/flash', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if BankTransactionMatcher.cancel(bank_transaction_rule_match)
      respond_to do |format|
        flash.now.notice = 'Match cancelled.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    else
      respond_to do |format|
        flash.now.notice = 'Match not cancelled.'
        format.turbo_stream { render partial: 'partials/flash', status: :unprocessable_entity }
      end
    end
  end

  private

  def bank_transaction_rule_match
    @bank_transaction_rule_match = current_organization.bank_transaction_rule_matches.find(params[:id])
  end
end
