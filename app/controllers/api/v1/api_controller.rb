# frozen_string_literal: true

module Api
  module V1
    class ApiController < ActionController::Base
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

      protect_from_forgery with: :null_session

      before_action :authenticate

      private

      def current_integration
        @authenticate_user_with_token
      end

      def current_organization
        @authenticate_user_with_token.organization
      end

      def authenticate
        authenticate_user_with_token || handle_bad_authentication
      end

      def authenticate_user_with_token
        authenticate_with_http_token do |token, _options|
          @authenticate_user_with_token ||= Integration.find_by(secret_key: token)
        end
      end

      def handle_bad_authentication
        render json: { error: 'Not authorized.' }, status: :unauthorized
      end

      def handle_not_found
        render json: { error: 'Record not found.' }, status: :not_found
      end
    end
  end
end
