require_relative '../test_helper'
require 'gds_api/test_helpers/worldwide'

class WorldLocationTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Worldwide

  context "loading all locations" do
    setup do
      @location_slugs = %w(the-shire rivendel rohan lorien gondor arnor mordor)
      worldwide_api_has_locations(@location_slugs)
    end

    should "load locations and construct an instance for each one" do
      results = WorldLocation.all
      assert results.first.is_a?(WorldLocation)
      assert_equal @location_slugs, results.map(&:slug)
    end
  end

  context "finding a location by slug" do
    should "return a corresponding instance if found" do
      worldwide_api_has_location('rohan')
      result = WorldLocation.find('rohan')
      assert result.is_a?(WorldLocation)
      assert_equal 'rohan', result.slug
      assert_equal 'Rohan', result.title
    end

    should "return nil if not found" do
      worldwide_api_does_not_have_location('non-existent')
      assert_nil WorldLocation.find('non-existent')
    end
  end

  context "accessing attributes" do
    setup do
      worldwide_api_has_location('rohan')
      @location = WorldLocation.find('rohan')
    end

    should "allow accessing required top-level attributes" do
      assert_equal "Rohan", @location.title
      assert_equal "Rohan", @location.name # alias for title
      assert_equal 'rohan', @location.details.slug
    end

    should "allow accessing required details attributes" do
      assert_equal 'rohan', @location.slug
    end
  end

  context "organisations" do
    setup do
      worldwide_api_has_location('rohan')
      @location = WorldLocation.find('rohan')
    end

    should "return the WorldwideOrganisations for the location slug" do
      WorldwideOrganisation.expects(:for_location).with("rohan").returns(:some_organisations)
      assert_equal :some_organisations, @location.organisations
    end

    should "memoize the result" do
      WorldwideOrganisation.expects(:for_location).once.returns(:some_organisations)
      @location.organisations
      assert_equal :some_organisations, @location.organisations
    end

    context "accessing the FCO organisation" do
      setup do
        @org1 = stub(:fco_sponsored? => false)
        @org2 = stub(:fco_sponsored? => true)
        @org3 = stub(:fco_sponsored? => false)
        @org4 = stub(:fco_sponsored? => true)
      end

      should "return the fco sponsored org" do
        WorldwideOrganisation.stubs(:for_location).once.returns([@org1, @org2, @org3])
        assert_equal @org2, @location.fco_organisation
      end

      should "return nil if there are no fco orgs" do
        WorldwideOrganisation.stubs(:for_location).once.returns([@org1, @org3])
        assert_equal nil, @location.fco_organisation
      end

      should "return the first if multiple match" do
        WorldwideOrganisation.stubs(:for_location).once.returns([@org1, @org2, @org3, @org4])
        assert_equal @org2, @location.fco_organisation
      end
    end
  end
end
