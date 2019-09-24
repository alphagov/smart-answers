require "gds_api/test_helpers/common_responses"
require "gds_api/response"

module WorldLocationStubbingMethods
  include GdsApi::TestHelpers::CommonResponses

  def stub_world_location(location_slug, load_fco_organisation_data: false)
    location = stub.quacks_like(WorldLocation.new({}))
    location.stubs(:slug).returns(location_slug)
    name = titleize_slug(location_slug, title_case: true)
    location.stubs(:name).returns(name)

    fco_organisation = nil
    if load_fco_organisation_data
      path_to_organisations_fixture = fixture_file("worldwide/#{location_slug}_organisations.json")
      if File.exist?(path_to_organisations_fixture)
        json = File.read(path_to_organisations_fixture)
        data = JSON.parse(json)
        organisations_data = data["results"]

        fco_organisation_data = organisations_data.find do |organisation_data|
          organisation_data["sponsors"].find do |sponsor_data|
            sponsor_data["details"]["acronym"] == "FCO"
          end
        end

        if fco_organisation_data
          fco_organisation = WorldwideOrganisation.new(fco_organisation_data)
        end
      end
    end
    location.stubs(:fco_organisation).returns(fco_organisation)

    WorldLocation.stubs(:find).with(location_slug).returns(location)
    location
  end

  def stub_world_locations(location_slugs, load_fco_organisation_data: false)
    locations = location_slugs.map do |slug|
      stub_world_location(slug, load_fco_organisation_data: load_fco_organisation_data)
    end
    WorldLocation.stubs(:all).returns(locations)
  end
end
