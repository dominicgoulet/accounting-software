# frozen_string_literal: true

class AppController < ApplicationController
  def dashboard; end

  def transactions
    render layout: 'transactions'
  end

  def documents
    # render layout: 'documents'
    redirect_to invoices_path
  end

  def launchpad; end

  def ledger
    @q = current_organization.journal_entries.order('date desc')
    @q = @q.ransack(params[:q])

    unless params[:q]
      @q.date_gteq = '2023-01-01'
      @q.date_lteq = '2023-12-31'
    end

    @journal_entries = @q.result(distinct: true).page(params[:page])

    render layout: 'ledger'
  end

  def shoebox; end

  def auditor; end
end
