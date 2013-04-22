require 'gds_api/helpers'

class WorldLocation
  extend Forwardable
  extend GdsApi::Helpers

  def self.all
    worldwide_api.world_locations.map do |l|
      new(l)
    end
  end

  def self.find(location_slug)
    data = worldwide_api.world_location(location_slug)
    self.new(data) if data
  end

  def initialize(data)
    @data = data
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
