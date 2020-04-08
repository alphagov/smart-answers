require "statsd"
require "gds_api"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi.publishing_api
  end

  def self.imminence_api
    @imminence_api ||= GdsApi.imminence
  end

  def self.worldwide_api
    @worldwide_api ||= GdsApi.worldwide
  end

  def self.content_store
    @content_store ||= GdsApi.content_store
  end

  def self.content_store=(new_content_store)
    @content_store = new_content_store
  end
end
