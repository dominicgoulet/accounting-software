# frozen_string_literal: true

module Api
  module V1
    class SalesTaxesController < Api::V1::ApiController
      def index
        render json: current_organization.sales_taxes
      end

      def show
        sales_tax = current_organization.sales_taxes.find(params[:id])

        render json: sales_tax, status: :ok
      end

      def create
        sales_tax = current_organization.sales_taxes.build(sales_tax_params)

        if sales_tax.save
          current_integration.log_event(sales_tax, 'create')

          render json: sales_tax, status: :created
        else
          render json: sales_tax.errors, status: :unprocessable_entity
        end
      end

      def update
        sales_tax = current_organization.sales_taxes.find(params[:id])

        if sales_tax.update(sales_tax_params)
          current_integration.log_event(sales_tax, 'update')

          head :no_content
        else
          render json: sales_tax.errors, status: :unprocessable_entity
        end
      end

      def destroy
        sales_tax = current_organization.sales_taxes.find(params[:id])

        if sales_tax.destroy
          current_integration.log_event(sales_tax, 'update')

          head :no_content
        else
          render json: sales_tax.errors, status: :unprocessable_entity
        end
      end

      private

      def sales_tax_params
        params[:sales_tax]&.permit(
          :name,
          :abbreviation,
          :number,
          :rate
        )
      end
    end
  end
end
