require 'gds_api/publishing_api_v2'
require 'gds_api/imminence'
require 'gds_api/worldwide'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def self.imminence_api
    @imminence_api ||= GdsApi::Imminence.new(Plek.new.find('imminence'))
  end

  def self.worldwide_api
    # In development, point at the public version of the API
    # as we won't normally have whitehall running
    if Rails.env.development?
      @worldwide_api ||= GdsApi::Worldwide.new("https://www.gov.uk")
    else
      @worldwide_api ||= GdsApi::Worldwide.new(Plek.new.find('whitehall-admin'))
    end
  end
end
