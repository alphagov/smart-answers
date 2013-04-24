require 'lrucache'

class WorldLocation
  extend Forwardable

  def self.cache
    @cache ||= LRUCache.new(:soft_ttl => 24.hours, :ttl => 1.week)
  end

  def self.reset_cache
    @cache = nil
  end

  def self.all
    cache.fetch("all") do
      begin
        $worldwide_api.world_locations.with_subsequent_pages.map do |l|
          new(l) if l.format == "World location"
        end.compact
      rescue GdsApi::BaseError => e
        # A Runtime Error is caught by LRUcache, and the stale value will be used if available
        raise RuntimeError.new("Error fetching world_locations: #{e.message}")
      end
    end
  end

  def self.find(location_slug)
    data = $worldwide_api.world_location(location_slug)
    self.new(data) if data
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
