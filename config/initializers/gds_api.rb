require 'gds_api/base'

GdsApi::Base.logger = Logger.new(Rails.root.join("log/#{Rails.env}.api_client.log"))
GdsApi::Base.default_options = { cache_size: 100 }
