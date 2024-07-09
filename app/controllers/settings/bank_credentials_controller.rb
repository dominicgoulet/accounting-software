# frozen_string_literal: true

module Settings
  class BankCredentialsController < Settings::SettingsController
    def index
      @bank_credentials = current_organization.bank_credentials
    end
  end
end
