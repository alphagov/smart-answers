require_relative '../test_helper'
require 'gds_api/test_helpers/worldwide'

class WorldLocationTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Worldwide

  context "loading all locations" do
    should "load locations and construct an instance for each one" do
      @location_slugs = %w(the-shire rivendel rohan lorien gondor arnor mordor)
      worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert results.first.is_a?(WorldLocation)
      assert_equal @location_slugs, results.map(&:slug)
    end

    should "load multiple pages of locations" do
      @location_slugs = (1..30).map {|n| "location-#{n}" }
      worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert_equal @location_slugs, results.map(&:slug)
    end

    should "filter out any results that aren't locations" do
      @location_slugs = %w(the-shire rivendel rohan delegation-to-lorien gondor arnor mordor)
      worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert_equal %w(the-shire rivendel rohan gondor arnor mordor), results.map(&:slug)
    end

    should "filter out any results that don't have a slug" do
      loc1 = world_location_details_for_slug('location-1')
      loc2 = world_location_details_for_slug('location-2')
      loc2["details"]["slug"] = nil
      loc3 = world_location_details_for_slug('location-3')
      loc3["details"]["slug"] = ""
      loc4 = world_location_details_for_slug('location-4')
      details = {"results" => [loc1, loc2, loc3, loc4]}
      response = GdsApi::ListResponse.new(stub(body: details.to_json, headers: {}), nil)

      Services.worldwide_api.stubs(:world_locations).returns(response)

      results = WorldLocation.all
      assert_equal %w(location-1 location-4), results.map(&:slug)
    end

    context "caching the results" do
      setup do
        @location_slugs = (1..30).map {|n| "location-#{n}" }
        worldwide_api_has_locations(@location_slugs)
      end

      should "cache the loaded locations" do
        first = WorldLocation.all
        second = WorldLocation.all

 assert_requested(:get, %r{\A#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations}, times: 2) # 2 pages of results, once each
        assert_equal first, second
      end

      should "cache the loaded locations for a day" do
        first = WorldLocation.all
        second = WorldLocation.all

 assert_requested(:get, %r{\A#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations}, times: 2) # 2 pages of results, once each
        assert_equal first, second

        Timecop.travel(Time.now + 23.hours) do
          third = WorldLocation.all
   assert_requested(:get, %r{\A#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations}, times: 2) # 2 pages of results, once each
          assert_equal first, third
        end

        Timecop.travel(Time.now + 25.hours) do
          fourth = WorldLocation.all
   assert_requested(:get, %r{\A#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations}, times: 4) # 2 pages of results, twice each
          assert_equal first, fourth
        end
      end

      should "use the stale value from the cache on error for a week" do
        first = WorldLocation.all

        stub_request(:get, "#{WORLDWIDE_API_ENDPOINT}/api/world-locations").to_timeout

        Timecop.travel(Time.now + 25.hours) do
          assert_nothing_raised do
            second = WorldLocation.all
            assert_equal first, second
          end
        end

        Timecop.travel(Time.now + 1.week + 1.hour) do
          assert_raises GdsApi::TimedOutException do
            WorldLocation.all
          end
        end
      end
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

    context "caching the result" do
      setup do
        worldwide_api_has_location('rohan')
        worldwide_api_has_location('gondor')
      end

      should "cache the loaded location" do
        first = WorldLocation.find('rohan')
        second = WorldLocation.find('rohan')

 assert_requested(:get, "#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations/rohan", times: 1)
        assert_equal first, second
      end

      should "not allow cached items to conflict" do
        WorldLocation.find('rohan')
        assert_equal 'gondor', WorldLocation.find('gondor').slug
      end

      should "cache the loaded location for a day" do
        first = WorldLocation.find('rohan')
        second = WorldLocation.find('rohan')

 assert_requested(:get, "#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations/rohan", times: 1)
        assert_equal first, second

        Timecop.travel(Time.now + 23.hours) do
          third = WorldLocation.find('rohan')
   assert_requested(:get, "#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations/rohan", times: 1)
          assert_equal first, third
        end

        Timecop.travel(Time.now + 25.hours) do
          fourth = WorldLocation.find('rohan')
   assert_requested(:get, "#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations/rohan", times: 2)
          assert_equal first, fourth
        end
      end

      should "use the stale value from the cache on error for a week" do
        first = WorldLocation.find('rohan')

        stub_request(:get, "#{GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT}/api/world-locations/rohan").to_timeout

        Timecop.travel(Time.now + 25.hours) do
          assert_nothing_raised do
            second = WorldLocation.find('rohan')
            assert_equal first, second
          end
        end

        Timecop.travel(Time.now + 1.week + 1.hour) do
          assert_raises GdsApi::TimedOutException do
            WorldLocation.find('rohan')
          end
        end
      end
    end
  end

  context "equality" do
    setup do
      worldwide_api_has_location('rohan')
      worldwide_api_has_location('gondor')
    end

    should "consider 2 location instances with the same slug as ==" do
      loc1 = WorldLocation.find('rohan')
      WorldLocation.reset_cache
      loc2 = WorldLocation.find('rohan')
      assert_not_equal loc1.object_id, loc2.object_id # Ensure we've got different instances
      assert loc1 == loc2
    end

    should "not consider instances with different slugs as ==" do
      loc1 = WorldLocation.find('rohan')
      loc2 = WorldLocation.find('gondor')
      refute loc1 == loc2
    end

    should "not consider instance of a different class as ==" do
      loc1 = WorldLocation.find('rohan')
      loc2 = OpenStruct.new(slug: 'rohan')
      refute loc1 == loc2
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
        @org1 = stub(fco_sponsored?: false)
        @org2 = stub(fco_sponsored?: true)
        @org3 = stub(fco_sponsored?: false)
        @org4 = stub(fco_sponsored?: true)
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
