require_relative "boot"

require "rails/all"
require 'rswag'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HwcWebservice
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.active_job.queue_adapter = :sidekiq
    config.load_defaults 7.0
    config.autoload_paths << "#{Rails.root}/lib"
    config.time_zone = "Asia/Kolkata"
    config.autoload_paths << Rails.root.join('app', 'swagger')
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Replace '*' with the specific origin(s) you want to allow
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # config.api_only = true
  end
end
