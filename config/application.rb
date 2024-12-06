require_relative "boot"

# We don't need activerecord or action_mailer
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "sprockets/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartAnswers
  class Application < Rails::Application
    include GovukPublishingComponents::AppHelpers::AssetHelper

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    config.govuk_time_zone = "London"

    Rails.application.config.action_view.form_with_generates_remote_forms = false
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/presenters]

    # New for rails 7.1 to enable previous autoload behaviour
    config.add_autoload_paths_to_load_path = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.allow_forgery_protection = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :"en-GB"
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]

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

    # Force lib autoload, which was removed by Rails 3.0 and enforced by Zeitwerk
    config.autoload_paths << Rails.root.join("lib")

    # Allow requests for all domains e.g. <app>.dev.gov.uk
    config.hosts.clear
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets data generators tasks])
  end
end
