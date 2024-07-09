# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body).to_json
    end

    def json_error_not_authorized
      %({"error":"Not authorized."})
    end

    def json_error_not_found
      %({"error":"Record not found."})
    end
  end
end
