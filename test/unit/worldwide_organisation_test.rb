require_relative '../test_helper'
require 'gds_api/test_helpers/worldwide'

class WorldwideOrganisationTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Worldwide

  context "finding organisations in a location" do
    should "return organisations for the location" do
      json = read_fixture_file('worldwide/australia_organisations.json')
      worldwide_api_has_organisations_for_location('australia', json)

      results = WorldwideOrganisation.for_location('australia')
      assert results[0].is_a?(WorldwideOrganisation)
      assert_equal ["UK Trade & Investment Australia", "British High Commission Canberra"], results.map(&:title)
    end
  end

  context "fco_sponsored?" do
    setup do
      json = read_fixture_file('worldwide/australia_organisations.json')
      worldwide_api_has_organisations_for_location('australia', json)
      @orgs = WorldwideOrganisation.for_location('australia')
    end

    should "return true for an organisation sponsored by the FCO" do
      assert_equal true, @orgs[1].fco_sponsored?
    end

    should "return false otherwise" do
      assert_equal false, @orgs[0].fco_sponsored?
    end
  end

  context "attribute accessors" do
    setup do
      json = read_fixture_file('worldwide/australia_organisations.json')
      worldwide_api_has_organisations_for_location('australia', json)
      @organisation = WorldwideOrganisation.for_location('australia')[1]
    end

    should "allow accessing required top-level attributes" do
      assert_equal "British High Commission Canberra", @organisation.title
    end

    context "accessing office details" do
      should "allow accessing office details" do
        assert_equal "British High Commission Canberra", @organisation.offices.main.title
      end

      should "have shortcut accessor for main office" do
        assert_equal "British High Commission Canberra", @organisation.main_office.title
      end

      should "have shortcut accessor for other offices" do
        assert_equal "British Consulate-General Sydney", @organisation.other_offices.first.title
      end

      should "have an accessor for all offices" do
        assert_equal 5, @organisation.all_offices.size
        assert_equal ["British High Commission Canberra", "British Consulate-General Sydney"], @organisation.all_offices.map(&:title)[0..1]
      end
    end
  end
end
