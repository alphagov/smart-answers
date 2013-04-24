class WorldLocation
  extend Forwardable

  def self.all
    $worldwide_api.world_locations.with_subsequent_pages.map do |l|
      new(l) if l.format == "World location"
    end.compact
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
