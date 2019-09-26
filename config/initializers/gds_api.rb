require "gds_api/base"

GdsApi::Base.default_options = {
  logger: Logger.new(Rails.root.join("log/#{Rails.env}.api_client.log")),
}
