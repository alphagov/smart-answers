require 'lrucache'

class WorldLocation
  extend Forwardable

  def self.cache
    @cache ||= LRUCache.new(max_size: 250, soft_ttl: 24.hours, ttl: 1.week)
  end

  def self.reset_cache
    @cache = nil
  end

  def self.all
    cache_fetch("all") do
      Services.worldwide_api.world_locations.with_subsequent_pages.map do |l|
        new(l) if l.format == "World location" and l.details and l.details.slug.present?
      end.compact
    end
  end

  def self.find(location_slug)
    cache_fetch("find_#{location_slug}") do
      data = Services.worldwide_api.world_location(location_slug)
      self.new(data) if data
    end
  end

  # Fetch a value from the cache.
  #
  # On GdsApi errors, returns a stale value from the cache if available,
  # otherwise re-raises the original GdsApi exception
  def self.cache_fetch(key)
    inner_exception = nil
    cache.fetch(key) do
      begin
        yield
      rescue GdsApi::BaseError => e
        inner_exception = e
        raise RuntimeError.new("use_stale_value")
      end
    end
  rescue RuntimeError => e
    if e.message == "use_stale_value"
      raise inner_exception
    else
      raise
    end
  end

  def initialize(data)
    @data = data
  end

  def ==(other)
    other.is_a?(self.class) and other.slug == self.slug
  end

  def_delegators :@data, :title, :details
  def_delegators :details, :slug
  alias_method :name, :title

  def organisations
    @organisations ||= WorldwideOrganisation.for_location(self.slug)
  end

  def fco_organisation
    self.organisations.find {|o| o.fco_sponsored? }
  end
end
