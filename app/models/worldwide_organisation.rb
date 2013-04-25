class WorldwideOrganisation
  extend Forwardable

  def self.for_location(location_slug)
    $worldwide_api.organisations_for_world_location(location_slug).map do |org|
      new(org)
    end
  end

  def initialize(data)
    @data = data
  end

  def_delegators :@data, :title, :offices
  def_delegator :offices, :main, :main_office
  def_delegator :offices, :other, :other_offices
  def all_offices
    [main_office] + other_offices
  end

  def fco_sponsored?
    @data.sponsors.any? {|s| s.details.acronym == "FCO" }
  end
end
