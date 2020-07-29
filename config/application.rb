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
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    Rails.application.config.action_view.form_with_generates_remote_forms = false
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/presenters]
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

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

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
