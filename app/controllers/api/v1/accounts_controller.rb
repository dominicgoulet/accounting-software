# frozen_string_literal: true

module Api
  module V1
    class AccountsController < Api::V1::ApiController
      def index
        render json: current_organization.accounts
      end

      def show
        account = current_organization.accounts.find(params[:id])

        render json: account, status: :ok
      end

      def create
        account = current_organization.accounts.build(account_params)

        if account.save
          current_integration.log_event(account, 'create')

          render json: account, status: :created
        else
          render json: account.errors, status: :unprocessable_entity
        end
      end

      def update
        account = current_organization.accounts.find(params[:id])

        if account.update(account_params)
          current_integration.log_event(account, 'update')

          head :no_content
        else
          render json: account.errors, status: :unprocessable_entity
        end
      end

      def destroy
        account = current_organization.accounts.find(params[:id])

        if account.destroy
          current_integration.log_event(account, 'update')

          head :no_content
        else
          render json: account.errors, status: :unprocessable_entity
        end
      end

      private

      def account_params
        params[:account]&.permit(
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
end
