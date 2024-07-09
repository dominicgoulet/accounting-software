# frozen_string_literal: true

class BankTransactionRulesController < ApplicationController
  layout 'transactions'

  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_bank_transaction_rule, only: %i[show edit update enforce destroy]

  def index
    @q = current_organization.bank_transaction_rules.ransack(params[:q])
    @bank_transaction_rules = @q.result
  end

  def show; end

  def new
    @bank_transaction_rule = BankTransactionRule.new

    return unless params[:bank_transaction_id].present?

    @bank_transaction = current_organization.bank_transactions.find(params[:bank_transaction_id])

    @bank_transaction_rule.name = @bank_transaction.name
    @bank_transaction_rule.bank_account_ids << @bank_transaction.bank_account_id
    @bank_transaction_rule.bank_transaction_rule_conditions.build(
      field: 'description',
      condition: 'contains',
      value: @bank_transaction.name
    )

    @bank_transaction_rule.bank_transaction_rule_conditions.build(
      field: 'amount',
      condition: 'is',
      value: @bank_transaction.debit? ? @bank_transaction.debit : @bank_transaction.credit
    )

    @bank_transaction_rule.contact = current_organization.contacts.find_by(display_name: @bank_transaction.merchant_name)

    if @bank_transaction.debit?
      @bank_transaction_rule.match_debit_or_credit = 'debit'
      @bank_transaction_rule.document_type = 'Deposit'
    else
      @bank_transaction_rule.match_debit_or_credit = 'credit'
      @bank_transaction_rule.document_type = 'Expense'
    end
  end

  def create
    @bank_transaction_rule = current_organization.bank_transaction_rules.build(bank_transaction_rule_params)

    if @bank_transaction_rule.save
      ninetyfour_integration.log_event(@bank_transaction_rule, 'create', current_user)

      respond_to do |format|
        flash.now.notice = 'Rule created successfully.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @bank_transaction_rule.update(bank_transaction_rule_params)
      ninetyfour_integration.log_event(@bank_transaction_rule, 'update', current_user)

      respond_to do |format|
        flash.now.notice = 'Rule updated successfully.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def enforce
    BankTransactionMatcher.enforce_rule(@bank_transaction_rule)

    respond_to do |format|
      flash.now.notice = 'Rule enforced successfully.'
      format.turbo_stream { render partial: 'partials/flash' }
    end
  end

  def destroy
    if @bank_transaction_rule.destroy
      ninetyfour_integration.log_event(@bank_transaction_rule, 'destroy', current_user)

      respond_to do |format|
        flash.now.notice = 'Rule deleted successfully.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    else
      respond_to do |format|
        flash.now.alert = 'Rule could not be deleted.'
        format.turbo_stream { render partial: 'partials/flash' }
      end
    end
  end

  def destroy_many
    @items = current_organization.bank_transaction_rules.where(id: params[:item_ids])
    destroyed_count = 0

    @items.each do |item|
      if item.destroy
        ninetyfour_integration.log_event(item, 'destroy', current_user)
        destroyed_count += 1
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = "#{destroyed_count} rules out of #{@items.size} were successfully deleted."
        render partial: 'partials/flash'
      end
    end
  end

  private

  def set_bank_transaction_rule
    @bank_transaction_rule = current_organization.bank_transaction_rules.find(params[:id])
  end

  def bank_transaction_rule_params
    params[:bank_transaction_rule].permit(
      :name,
      :match_debit_or_credit,
      :match_all_conditions,
      :action,
      :contact_id,
      :document_type,
      :auto_apply,
      bank_transaction_rule_conditions_attributes: %i[
        id
        field
        condition
        value
        _destroy
      ],

      bank_transaction_rule_document_lines_attributes: [
        :id,
        :percentage,
        :account_id,
        :_destroy,

        { bank_transaction_rule_document_line_taxes_attributes: %i[
          id
          sales_tax_id
          _destroy
        ] }
      ],

      bank_account_ids: []
    )
  end
end
