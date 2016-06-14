require 'gds_api/test_helpers/common_responses'
require 'hashugar'

module WorldLocationStubbingMethods
  include GdsApi::TestHelpers::CommonResponses

  def stub_world_location(location_slug)
    location = stub.quacks_like(WorldLocation.new({}))
    location.stubs(:slug).returns(location_slug)
    name = titleize_slug(location_slug, title_case: true)
    location.stubs(:name).returns(name)

    path_to_organisations_fixture = fixture_file("worldwide/#{location_slug}_organisations.json")
    organisations = []
    if File.exist?(path_to_organisations_fixture)
      json = File.read(path_to_organisations_fixture)
      data = JSON.parse(json)
      organisations = data['results'].map do |organisation_data|
        organisation = organisation_data.to_hashugar
        WorldwideOrganisation.new(organisation)
      end
    end
    location.stubs(:organisations).returns(organisations)
    location.stubs(:fco_organisation).returns(organisations.find(&:fco_sponsored?))

    WorldLocation.stubs(:find).with(location_slug).returns(location)
    location
  end

  def stub_world_locations(location_slugs)
    locations = location_slugs.map do |slug|
      stub_world_location(slug)
    end
    WorldLocation.stubs(:all).returns(locations)
  end
end
