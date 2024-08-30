require_relative "boot"

# Don't include all of rails, we don't need activerecord or action_mailer
require "action_controller/railtie"
require "active_model/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartAnswers
  class Application < Rails::Application
    include GovukPublishingComponents::AppHelpers::AssetHelper

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.govuk_time_zone = "London"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.allow_forgery_protection = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :"en-GB"
    config.i18n.fallbacks = true

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/smartanswers"

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = "1.0"
    config.action_dispatch.ignore_accept_header = true
    # Allow requests for all domains e.g. <app>.dev.gov.uk
    config.hosts.clear
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets data tasks])
  end
end
