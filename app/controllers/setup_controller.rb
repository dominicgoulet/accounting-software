# frozen_string_literal: true

class SetupController < ApplicationController
  def new
    return unless request.patch?

    redirect_to next_step[:path]
  end

  def about
    return unless request.patch?

    if params[:user].present?
      current_user.first_name = params[:user][:first_name]
      current_user.last_name = params[:user][:last_name]

      if current_user.save
        redirect_to next_step[:path]
      else
        render :about, status: :unprocessable_entity
      end
    else
      render :about, status: :unprocessable_entity
    end
  end

  def organization
    return unless request.patch?

    if params[:organization].present?
      current_organization.name = params[:organization][:name]
      current_organization.website = params[:organization][:website]

      if current_organization.save
        redirect_to next_step[:path]
      else
        render :organization, status: :unprocessable_entity
      end
    else
      render :organization, status: :unprocessable_entity
    end
  end

  def bank
    return unless request.patch?

    redirect_to next_step[:path]
  end

  def import
    @quickbooks_integration = current_organization.integrations.find_by(internal_code: 'QUICKBOOKS')

    if request.post?
      if @quickbooks_integration.present?
        i = QuickbooksIntegration.new(@quickbooks_integration)
        i.import

        redirect_to setup_import_path
      else
        current_organization.integrations.create(name: 'Quickbook Import', internal_code: 'QUICKBOOKS')

        redirect_to setup_import_path
      end
    end

    if request.patch?
      redirect_to next_step[:path]
    end
  end

  def account
    return unless request.patch?

    current_organization.setup_completed!
    redirect_to root_path
  end

  def setup_steps
    [
      {
        id: 'ABOUT',
        label: 'About yourself',
        path: setup_about_path
      },
      {
        id: 'ORGANIZATION',
        label: 'Your organization',
        path: setup_organization_path
      },
      {
        id: 'BANK',
        label: 'Bank information (optional)',
        path: setup_bank_path
      },
      {
        id: 'IMPORT',
        label: 'Import data (optional)',
        path: setup_import_path
      },
      {
        id: 'COMPLETED',
        label: 'Account',
        path: setup_account_path
      }
    ]
  end
  helper_method :setup_steps

  def current_step_index
    setup_steps.each_with_index do |step, index|
      return index if step[:path] == request.path
    end
    -1
  end
  helper_method :current_step_index

  def next_step
    idx = current_step_index + 1
    return setup_steps[idx] if idx < setup_steps.size
  end
  helper_method :next_step

  def step_color(index)
    if index == current_step_index
      'primary'
    elsif index < current_step_index
      'success'
    end
  end
  helper_method :step_color
end
