class WorldLocation
  attr_reader :title, :details, :slug

  def self.cache
    @cache ||= {
      day: ActiveSupport::Cache::MemoryStore.new(expires_in: 24.hours),
      week: ActiveSupport::Cache::MemoryStore.new(expires_in: 1.week),
    }
  end

  def self.reset_cache
    cache[:day].clear
    cache[:week].clear
  end

  def self.all
    cache_fetch("all") do
      world_locations = Services.worldwide_api
        .world_locations
        .with_subsequent_pages
        .each_with_object([]) do |response, locations|
          location = response.to_hash
          if valid_world_location_format?(location)
            locations << self.new(location)
          end
        end

      raise NoLocationsFromWorldwideApiError if world_locations.empty?

      world_locations
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
    value = cache[:day].read(key)
    return value unless value.nil?

    begin
      value = yield
      cache[:day].write(key, value)
      cache[:week].write(key, value)
    rescue GdsApi::BaseError => e
      value = cache[:week].read(key)
      raise e if value.nil?
    end

    value
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

  class NoLocationsFromWorldwideApiError < StandardError; end
end
