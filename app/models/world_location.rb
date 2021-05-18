class WorldLocation
  attr_reader :title, :details, :slug

  def self.all
    Rails.cache.fetch("all", expires_in: 24.hours) do
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
    Rails.cache.fetch("find_#{location_slug}", expires_in: 24.hours) do
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
