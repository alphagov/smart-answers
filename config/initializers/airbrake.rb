# This file is overwritten on deploy

Airbrake.configure do |config|
  config.api_key = ENV["ERRBIT_API_KEY"]
  config.host    = ENV["ERRBIT_HOST"]
  config.environment_name = ENV["ERRBIT_ENV"]
  config.secure = ENV["ERRBIT_API_KEY"].present?
end
