class WorldwideOrganisation
  extend Forwardable

  def self.for_location(location_slug)
    Services.worldwide_api.organisations_for_world_location(location_slug).map do |org|
      new(org)
    end
  end

  def initialize(data)
    @data = data
  end

  def_delegators :@data, :title, :offices, :web_url
  def_delegator :offices, :main, :main_office
  def_delegator :offices, :other, :other_offices

  def all_offices
    [main_office] + other_offices
  end

  def fco_sponsored?
    @data.sponsors.any? {|s| s.details.acronym == "FCO" }
  end

  def offices_with_service(service_title)
    return [] unless all_offices.any?
    embassies = all_offices.select do |o|
      o.services.any? { |s| s.title.include?(service_title) }
    end
    embassies << main_office if embassies.empty?
    embassies
  end
end
