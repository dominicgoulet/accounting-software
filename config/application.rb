# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ninetyfour
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]

    config.view_component.generate_stimulus_controller = true
    config.view_component.generate_locale = true
    config.view_component.generate_distinct_locale_files = true
    config.view_component.generate.sidecar = true

    config.view_component.default_preview_layout = 'component_preview'

    Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }

    config.active_storage.replace_on_assign_to_many = false

    config.active_record.encryption.primary_key = ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY']
    config.active_record.encryption.deterministic_key = ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY']
    config.active_record.encryption.key_derivation_salt = ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT']
  end
end
