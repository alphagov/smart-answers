require "govuk_app_config/govuk_puma"

if ENV["RAILS_ENV"] == "test"
  silence_single_worker_warning if respond_to?(:silence_single_worker_warning)
else
  GovukPuma.configure_rails(self)
end
