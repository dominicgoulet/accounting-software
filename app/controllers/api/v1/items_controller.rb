# frozen_string_literal: true

module Api
  module V1
    class ItemsController < Api::V1::ApiController
      def index
        render json: current_organization.items
      end

      def show
        item = current_organization.items.find(params[:id])

        render json: item, status: :ok
      end

      def create
        item = current_organization.items.build(item_params)

        if item.save
          current_integration.log_event(item, 'create')

          render json: item, status: :created
        else
          render json: item.errors, status: :unprocessable_entity
        end
      end

      def update
        item = current_organization.items.find(params[:id])

        if item.update(item_params)
          current_integration.log_event(item, 'update')

          head :no_content
        else
          render json: item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        item = current_organization.items.find(params[:id])

        if item.destroy
          current_integration.log_event(item, 'update')

          head :no_content
        else
          render json: item.errors, status: :unprocessable_entity
        end
      end

      private

      def item_params
        params[:item]&.permit(
          :expense_account_id,
          :income_account_id,
          :buy,
          :buy_description,
          :buy_price,
          :cup,
          :name,
          :sell,
          :sell_description,
          :sell_price,
          :ugs
        )
      end
    end
  end
end
