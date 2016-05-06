require 'gds_api/publishing_api_v2'
require 'gds_api/imminence'
require 'gds_api/worldwide'
require 'gds_api/content_api'

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
    @worldwide_api ||= GdsApi::Worldwide.new(Plek.new.find('whitehall-admin'))
  end

  def self.content_api
    @content_api ||= GdsApi::ContentApi.new(Plek.new.find("contentapi"))
  end
end
