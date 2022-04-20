require_relative "boot"

require "action_controller/railtie"
require "active_model/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartAnswers
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.time_zone = "London"

    Rails.application.config.action_view.form_with_generates_remote_forms = false
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/presenters]
    config.allow_forgery_protection = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :"en-GB"
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.yml")]
    config.i18n.fallbacks = true

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/smartanswers"

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # allow overriding the asset host with an enironment variable, useful for
    # when router is proxying to this app but asset proxying isn't set up.
    config.asset_host = ENV["ASSET_HOST"]

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w[
      joint.patch.js
      joint.js
      joint.layout.DirectedGraph.js
      joint.css
      print.css
      dagre.js
      visualise.js
      visualise.css
    ]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = "1.0"

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil

    config.action_dispatch.ignore_accept_header = true

    config.eager_load_paths << Rails.root.join("lib")

    # Allow requests for all domains e.g. <app>.dev.gov.uk
    config.hosts.clear
  end
end
