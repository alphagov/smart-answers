require_relative "boot"

# Don't include all of rails, we don't need activerecord or action_mailer
require "action_controller/railtie"
require "active_model/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "govuk_publishing_components/middleware/ga4_optimise"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartAnswers
  class Application < Rails::Application
    include GovukPublishingComponents::AppHelpers::AssetHelper

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.govuk_time_zone = "London"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    Rails.application.config.action_view.form_with_generates_remote_forms = false

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/presenters]
    config.add_autoload_paths_to_load_path = true

    config.allow_forgery_protection = false

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :"en-GB"
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.i18n.fallbacks = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += %i[password]

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/smartanswers"

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = "1.0"

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil

    config.action_dispatch.ignore_accept_header = true

    # We have to load the old fashioned way as Zeitwerk does not work correctly
    # with config.autoload_lib in 7.1 with our current file structure.
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Allow requests for all domains e.g. <app>.dev.gov.uk
    config.hosts.clear

    # Use the middleware to compact data-ga4-event/link attributes
    config.middleware.use GovukPublishingComponents::Middleware::Ga4Optimise
  end
end
