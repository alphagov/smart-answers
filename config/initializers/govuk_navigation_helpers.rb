GovukNavigationHelpers.configure do |config|
  config.error_handler = Airbrake
  config.statsd = Services.statsd
end
