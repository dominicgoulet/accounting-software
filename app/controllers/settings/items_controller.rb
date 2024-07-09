# frozen_string_literal: true

module Settings
  class ItemsController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit]
    before_action :set_item, only: %i[show edit update destroy]

    def index
      redirect_to items_kind_path(:all) unless params[:kind].present? && %w[buy sell all].include?(params[:kind])

      @kind = params[:kind]

      @q = case @kind
           when 'buy' then current_organization.items.where(buy: true).ransack(params[:q])
           when 'sell' then current_organization.items.where(sell: true).ransack(params[:q])
           else current_organization.items.ransack(params[:q])
           end

      @items = @q.result
    end

    def show; end

    def new
      @item = Item.new(sell: true)
    end

    def new_contextual
      @item = Item.new(sell: true)
    end

    def create
      @item = current_organization.items.build(item_params)

      if @item.save
        ninetyfour_integration.log_event(@item, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Item created successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @item.update(item_params)
        ninetyfour_integration.log_event(@item, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Item updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @item.destroy
        ninetyfour_integration.log_event(@item, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Item deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Item could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.items.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} items out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_item
      @item = current_organization
              .items
              .find(params[:id])
    end

    def item_params
      params[:item].permit(
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
