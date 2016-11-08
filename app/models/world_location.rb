require 'lrucache'

class WorldLocation
  attr_reader :title, :details, :slug

  def self.cache
    @cache ||= LRUCache.new(max_size: 250, soft_ttl: 24.hours, ttl: 1.week)
  end

  def self.reset_cache
    @cache = nil
  end

  def self.all
    cache_fetch("all") do
      world_locations = Services.worldwide_api.world_locations.with_subsequent_pages.map do |response|
        location = response.to_hash
        if valid_world_location_format?(location)
          self.new(location)
        end
      end
      world_locations.compact
    end
  end

  def self.find(location_slug)
    cache_fetch("find_#{location_slug}") do
      location = Services.worldwide_api.world_location(location_slug)&.to_hash
      self.new(location) if location
    end
  end

  def self.valid_world_location_format?(location)
    location.is_a?(Hash) && location["format"] == "World location" &&
      location["details"].is_a?(Hash) && location["details"]["slug"].present?
  end
  private_class_method :valid_world_location_format?

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

  def initialize(location)
    @title = location.fetch("title", "")
    @details = location.fetch("details", {})
    @slug = @details.fetch("slug", "")
  end

  alias_method :name, :title

  def ==(other)
    other.is_a?(self.class) && other.slug == @slug
  end

  def organisations
    @organisations ||= WorldwideOrganisation.for_location(@slug)
  end

  def fco_organisation
    self.organisations.find(&:fco_sponsored?)
  end
end
