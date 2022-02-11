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
    @travel_rules ||= YAML.load_file(Rails.root.join("config/smart_answers/check_travel_during_coronavirus/country_data.yml"))
  end

  def initialize(location)
    @title = location.fetch("title", "")
    @details = location.fetch("details", {})
    @slug = @details.fetch("slug", "")
  end

  alias_method :name, :title

  def on_red_list?
    covid_status == "red"
  end

  def covid_status
    current_covid_status_data&.dig("covid_status")
  end

  def next_covid_status
    next_covid_status_data&.dig("covid_status")
  end

  def next_covid_status_applies_at
    Time.zone.parse(next_covid_status_data["covid_status_applies_at"])
  rescue NoMethodError, TypeError
    nil
  end

  def current_covid_status_data
    current_statuses = covid_status_data_for_location&.select do |status|
      start_date = Time.zone.parse(status["covid_status_applies_at"])
      start_date.past?
    end

    return if current_statuses.blank?

    current_statuses.max_by { |status| status["covid_status_applies_at"] }
  end

  def next_covid_status_data
    future_statuses = covid_status_data_for_location&.select do |status|
      start_date = Time.zone.parse(status["covid_status_applies_at"])
      start_date.future?
    end

    return if future_statuses.blank?

    future_statuses.min_by { |status| status["covid_status_applies_at"] }
  end

  def covid_status_data_for_location
    # Once the world location api returns the covid status, we should be able
    # to replace this line with:
    # location.fetch("england_coronavirus_travel", "")

    return if self.class.travel_rules.blank?

    rules = self.class.travel_rules["results"].select { |country| country["details"]["slug"] == slug }.first

    return if rules.blank?

    rules["england_coronavirus_travel"]
  end

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
