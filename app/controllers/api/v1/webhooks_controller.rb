# frozen_string_literal: true

module Api
  module V1
    class WebhooksController < ActionController::Base
      skip_before_action :verify_authenticity_token

      def create
        # Handle the webhook we just received
        head :no_content
      end
    end
  end
end
