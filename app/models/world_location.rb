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
      world_locations = GdsApi.worldwide
                              .world_locations
                              .with_subsequent_pages
                              .select { |r| valid_world_location_format?(r.to_hash) }
                              .map { |r| new(r.to_hash) }

      raise NoLocationsFromWorldwideApiError if world_locations.empty?

      world_locations
    end
  end

  def self.find(location_slug)
    cache_fetch("find_#{location_slug}") do
      location = GdsApi.worldwide.world_location(location_slug).to_hash
      new(location)
    rescue GdsApi::HTTPNotFound
      nil
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

  def self.travel_rules
    @travel_rules ||= YAML.load_file(Rails.root.join("config/smart_answers/check_travel_during_coronavirus_data.yml"))
  end

  def covid_status
    # Once the world location api returns the covid status, we should be able
    # to replace this line with:
    # location.fetch("england_coronavirus_travel", "")
    rules = self.class.travel_rules["results"].select { |country| country["details"]["slug"] == slug }.first

    return if rules.blank?

    rules["england_coronavirus_travel"]["covid_status"]
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
    organisations.find(&:fco_sponsored?)
  end

  class NoLocationsFromWorldwideApiError < StandardError; end
end
