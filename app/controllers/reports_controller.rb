# frozen_string_literal: true

class ReportsController < ApplicationController
  layout 'reports'
  before_action :set_report_query_params

  def index
    redirect_to balance_sheet_reports_path
  end

  def overview
    @report = OverviewReport.new(current_organization.id)
    @data = @report.execute
  end

  def balance_sheet
    @report = BalanceSheetReport.new(current_organization.id)

    @report.date = @q[:date_eq]
    @report.business_unit_id = @q[:business_unit_id_eq]
    @report.integration_id = @q[:integration_id_eq]

    @data = @report.execute
  end

  def profit_and_loss
    @report = ProfitAndLossReport.new(current_organization.id)

    @report.start_date = @q[:date_gteq]
    @report.end_date = @q[:date_lteq]
    @report.business_unit_id = @q[:business_unit_id_eq]
    @report.integration_id = @q[:integration_id_eq]

    @data = @report.execute
  end

  def cashflow
    @report = CashflowReport.new(current_organization.id)
    @data = @report.execute
  end

  def account_payable_aging
    @report = AccountPayableAgingReport.new(current_organization.id)
    @data = @report.execute
  end

  def account_receivable_aging
    @report = AccountReceivableAgingReport.new(current_organization.id)
    @data = @report.execute
  end

  def sales_tax
    @report = SalesTaxReport.new(current_organization.id)

    @report.start_date = @q[:date_gteq]
    @report.end_date = @q[:date_lteq]
    @report.business_unit_id = @q[:business_unit_id_eq]
    @report.integration_id = @q[:integration_id_eq]

    @data = @report.execute
  end

  def account
    @account = current_organization.accounts.find(params[:account_id])

    @report = AccountReport.new(current_organization.id, params[:account_id])
    @data = @report.execute
  end

  private

  def set_report_query_params
    @q = {
      date_eq: (params[:q] || {})[:date_eq] || Date.today.to_s,
      date_gteq: (params[:q] || {})[:date_gteq] || Date.new(Date.today.year, 1, 1).to_s,
      date_lteq: (params[:q] || {})[:date_lteq] || Date.today.to_s
    }
  end
end
