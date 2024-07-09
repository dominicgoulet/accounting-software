# frozen_string_literal: true

module Settings
  class SalesTaxesController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit]
    before_action :set_sales_tax, only: %i[show edit update destroy]

    def index
      @q = current_organization.sales_taxes.ransack(params[:q])
      @sales_taxes = @q.result
    end

    def show; end

    def new
      @sales_tax = SalesTax.new
    end

    def new_contextual
      @sales_tax = SalesTax.new
    end

    def create
      @sales_tax = current_organization.sales_taxes.build(sales_tax_params)

      if @sales_tax.save
        ninetyfour_integration.log_event(@sales_tax, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Sales tax created successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @sales_tax.update(sales_tax_params)
        ninetyfour_integration.log_event(@sales_tax, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Sales tax updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @sales_tax.destroy
        ninetyfour_integration.log_event(@sales_tax, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Sales tax deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Sales tax could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.sales_taxes.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} sales tax out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_sales_tax
      @sales_tax = current_organization.sales_taxes.find(params[:id])
    end

    def sales_tax_params
      params[:sales_tax].permit(
        :name,
        :abbreviation,
        :number,
        :rate
      )
    end
  end
end
