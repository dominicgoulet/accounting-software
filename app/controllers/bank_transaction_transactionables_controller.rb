# frozen_string_literal: true

class BankTransactionTransactionablesController < ApplicationController
  # before_action :ensure_frame_response, only: [:new, :edit]
  before_action :set_bank_transaction, only: %i[new create]
  before_action :set_bank_transaction_transactionable, only: %i[destroy]

  def new
    @bank_transaction_transactionable = @bank_transaction.bank_transaction_transactionables.build

    contact = current_organization.contacts.find_by(display_name: @bank_transaction.merchant_name)

    if @bank_transaction.credit?
      @bank_transaction_transactionable.transactionable = Expense.new(
        account: @bank_transaction.account,
        contact:,
        date: @bank_transaction.date,
        expense_lines: [
          ExpenseLine.new(
            quantity: 1,
            unit_price: @bank_transaction.amount.abs,
            description: @bank_transaction.name
          )
        ]
      )
    elsif @bank_transaction.debit?
      @bank_transaction_transactionable.transactionable = Deposit.new(
        account: @bank_transaction.account,
        contact:,
        date: @bank_transaction.date,
        deposit_lines: [
          DepositLine.new(
            quantity: 1,
            unit_price: @bank_transaction.amount.abs,
            description: @bank_transaction.name
          )
        ]
      )
    end
  end

  def create
    @bank_transaction_transactionable = @bank_transaction.bank_transaction_transactionables.build

    @status = @bank_transaction.status
    @bank_account = @bank_transaction.bank_account
    @q = @bank_account.bank_transactions.where(status: @status).ransack(params[:q])
    @bank_transactions = @q.result.page(params[:page])

    case params[:bank_transaction_transactionable][:transactionable_type]
    when 'Transfer'
      transfer = current_organization.transfers.build(transfer_params)

      # Force transaction values
      if @bank_transaction.amount.negative?
        transfer.from_account = @bank_transaction.account
      else
        transfer.to_account = @bank_transaction.account
      end
      transfer.date = @bank_transaction.date
      transfer.note = @bank_transaction.name

      @bank_transaction_transactionable.transactionable = transfer
    when 'Deposit'
      deposit = current_organization.deposits.build(deposit_params)

      # Force transaction values
      deposit.account = @bank_transaction.account
      deposit.date = @bank_transaction.date

      @bank_transaction_transactionable.transactionable = deposit
    when 'Expense'
      expense = current_organization.expenses.build(expense_params)

      # Force transaction values
      expense.account = @bank_transaction.account
      expense.date = @bank_transaction.date

      @bank_transaction_transactionable.transactionable = expense
    when 'InvoicePayment'
      invoice_payment = current_organization.payments.build(invoice_payment_params)
      invoice_payment.account = @bank_transaction.account
      invoice_payment.amount = @bank_transaction.amount.abs
      invoice_payment.date = @bank_transaction.date

      @bank_transaction_transactionable.transactionable = invoice_payment
    when 'BillPayment'
      bill_payment = current_organization.bill_payments.build(bill_payment_params)
      bill_payment.account = @bank_transaction.account
      bill_payment.amount = @bank_transaction.amount
      bill_payment.date = @bank_transaction.date

      @bank_transaction_transactionable.transactionable = bill_payment
    end

    if @bank_transaction_transactionable.save
      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Description created successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @status = @bank_transaction_transactionable.bank_transaction.status
    @bank_account = @bank_transaction_transactionable.bank_transaction.bank_account

    respond_to do |format|
      if @bank_transaction_transactionable.destroy
        format.turbo_stream do
          flash.now.notice = 'Description destroyed successfully.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  private

  def set_bank_transaction
    @bank_transaction = current_organization.bank_transactions.find(params[:bank_transaction_id])
  end

  def set_bank_transaction_transactionable
    @bank_transaction_transactionable = current_organization.bank_transaction_transactionables.find(params[:id])
  end

  def transfer_params
    params[:bank_transaction_transactionable][:transactionable].permit(
      :to_account_id,
      :from_account_id,
      :date,
      :amount,
      :note
    )
  end

  def deposit_params
    params[:bank_transaction_transactionable][:transactionable].permit(
      :contact_id,
      :account_id,
      :number,
      :date,
      :status,
      :taxes_calculation,
      deposit_taxes_attributes: %i[
        id
        sales_tax_id
        calculate_from_rate
        amount
        _destroy
      ],
      deposit_lines_attributes: [
        :id,
        :description,
        :account_id,
        :quantity,
        :unit_price,
        :_destroy,
        { deposit_line_taxes_attributes: %i[
          id
          sales_tax_id
          _destroy
        ] }
      ]
    )
  end

  def expense_params
    params[:bank_transaction_transactionable][:transactionable].permit(
      :contact_id,
      :account_id,
      :number,
      :date,
      :status,
      :taxes_calculation,
      expense_taxes_attributes: %i[
        id
        sales_tax_id
        calculate_from_rate
        amount
        _destroy
      ],
      expense_lines_attributes: [
        :id,
        :description,
        :account_id,
        :quantity,
        :unit_price,
        :_destroy,
        { expense_line_taxes_attributes: %i[
          id
          sales_tax_id
          _destroy
        ] }
      ]
    )
  end

  def invoice_payment_params
    params[:bank_transaction_transactionable][:transactionable].permit(
      :invoice_id
    )
  end

  def bill_payment_params
    params[:bank_transaction_transactionable][:transactionable].permit(
      :bill_id
    )
  end
end
