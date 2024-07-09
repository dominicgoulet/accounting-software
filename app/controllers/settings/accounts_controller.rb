# frozen_string_literal: true

module Settings
  class AccountsController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit]
    before_action :set_account, only: %i[show edit update destroy]

    def index
      unless params[:classification].present? && Account.classification.values.include?(params[:classification])
        redirect_to accounts_classification_path('asset')
      end

      @classification = params[:classification]
      @q = current_organization.accounts.where(classification: @classification).ransack(params[:q])
      @accounts = @q.result
    end

    def show; end

    def new
      @account = Account.new(classification: params[:classification])
    end

    def new_contextual
      @account = Account.new
    end

    def create
      @account = current_organization.accounts.build(account_params)

      if @account.save
        ninetyfour_integration.log_event(@account, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Account created successfully.'
            render partial: 'partials/flash'
          end
          format.json { render json: { id: @account.id, display_name: @account.display_name }, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @account.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit; end

    def update
      if @account.update(account_params)
        ninetyfour_integration.log_event(@account, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Account updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @account.destroy
        ninetyfour_integration.log_event(@account, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Account deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Account could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.accounts.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} accounts out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_account
      @account = current_organization.accounts.find(params[:id])
    end

    def account_params
      params[:account].permit(
        :parent_account_id,
        :classification,
        :reference,
        :name,
        :starting_balance,
        sales_tax_ids: []
      )
    end
  end
end
