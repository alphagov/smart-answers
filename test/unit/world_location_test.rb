require_relative "../test_helper"

class WorldLocationTest < ActiveSupport::TestCase
  context "loading all locations" do
    should "load locations and construct an instance for each one" do
      @location_slugs = %w[the-shire rivendel rohan lorien gondor arnor mordor]
      stub_worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert results.first.is_a?(WorldLocation)
      assert_equal @location_slugs, results.map(&:slug)
    end

    should "load multiple pages of locations" do
      @location_slugs = (1..30).map { |n| "location-#{n}" }
      stub_worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert_requested :get,
                       %r{\A#{WORLDWIDE_API_ENDPOINT}/api/world-locations},
                       times: 2
      assert_equal @location_slugs, results.map(&:slug)
    end

    should "filter out any results that are not world locations e.g. delegations & missions" do
      @location_slugs = %w[the-shire rivendel rohan delegation-to-lorien gondor arnor mission-to-mordor]
      stub_worldwide_api_has_locations(@location_slugs)

      results = WorldLocation.all
      assert_equal %w[the-shire rivendel rohan gondor arnor], results.map(&:slug)
    end

    should "filter out any results that don't have a slug" do
      stub_worldwide_api_has_locations(["location-1", "", "location-3"])

      results = WorldLocation.all
      assert_equal %w[location-1 location-3], results.map(&:slug)
    end

    context "caching the results" do
      setup do
        @location_slugs = (1..10).map { |n| "location-#{n}" }
        @endpoint = %r{\A#{WORLDWIDE_API_ENDPOINT}/api/world-locations}
        stub_worldwide_api_has_locations(@location_slugs)
      end

      should "cache the loaded locations" do
        first = WorldLocation.all
        second = WorldLocation.all

        assert_requested :get, @endpoint, times: 1
        assert_equal first, second
      end

      should "cache the loaded locations for a day" do
        first = WorldLocation.all

        travel_to(23.hours.from_now) do
          second = WorldLocation.all
          assert_requested :get, @endpoint, times: 1
          assert_equal first, second
        end

        travel_to(25.hours.from_now) do
          third = WorldLocation.all
          assert_requested :get, @endpoint, times: 2
          assert_equal first, third
        end
      end

      should "use the stale value from the cache on error for a week" do
        first = WorldLocation.all

        stub_request(:get, "#{WORLDWIDE_API_ENDPOINT}/api/world-locations").to_timeout

        travel_to(25.hours.from_now) do
          assert_nothing_raised do
            second = WorldLocation.all
            assert_equal first, second
          end
        end

        travel_to(1.week.from_now + 1.hour) do
          assert_raises GdsApi::TimedOutException do
            WorldLocation.all
          end
        end
      end
    end

    context "the Worldwide API returns no locations" do
      setup do
        stub_request(:get, "#{WORLDWIDE_API_ENDPOINT}/api/world-locations")
          .to_return(
            status: 200,
            body: {
              "results" => [],
            }.to_json,
            headers: {},
          )
      end

      should "raise an error" do
        assert_raises WorldLocation::NoLocationsFromWorldwideApiError do
          WorldLocation.all
        end
      end

      should "raise an error regardless of caching" do
        assert_raises WorldLocation::NoLocationsFromWorldwideApiError do
          WorldLocation.all
        end

        assert_raises WorldLocation::NoLocationsFromWorldwideApiError do
          WorldLocation.all
        end
      end
    end
  end

  context "finding a location by slug" do
    should "return a corresponding instance if found" do
      stub_worldwide_api_has_location("rohan")
      result = WorldLocation.find("rohan")
      assert result.is_a?(WorldLocation)
      assert_equal "rohan", result.slug
      assert_equal "Rohan", result.title
    end

    should "return nil if not found" do
      stub_worldwide_api_does_not_have_location("non-existent")
      assert_nil WorldLocation.find("non-existent")
    end

    context "caching the result" do
      setup do
        @rohan_request = stub_worldwide_api_has_location("rohan")
        stub_worldwide_api_has_location("gondor")
      end

      should "cache the loaded location" do
        first = WorldLocation.find("rohan")
        second = WorldLocation.find("rohan")

        assert_requested @rohan_request, times: 1
        assert_equal first, second
      end

      should "not allow cached items to conflict" do
        WorldLocation.find("rohan")
        assert_equal "gondor", WorldLocation.find("gondor").slug
      end

      should "cache the loaded location for a day" do
        first = WorldLocation.find("rohan")

        travel_to(23.hours.from_now) do
          second = WorldLocation.find("rohan")
          assert_requested @rohan_request, times: 1
          assert_equal first, second
        end

        travel_to(25.hours.from_now) do
          third = WorldLocation.find("rohan")
          assert_requested @rohan_request, times: 2
          assert_equal first, third
        end
      end

      should "use the stale value from the cache on error for a week" do
        first = WorldLocation.find("rohan")
        @rohan_request.to_timeout

        travel_to(25.hours.from_now) do
          assert_nothing_raised do
            second = WorldLocation.find("rohan")
            assert_equal first, second
          end
        end

        travel_to(1.week.from_now + 1.hour) do
          assert_raises GdsApi::TimedOutException do
            WorldLocation.find("rohan")
          end
        end
      end
    end
  end

  context "equality" do
    setup do
      stub_worldwide_api_has_location("rohan")
      stub_worldwide_api_has_location("gondor")
    end

    should "consider 2 location instances with the same slug as ==" do
      loc1 = WorldLocation.find("rohan")
      WorldLocation.reset_cache
      loc2 = WorldLocation.find("rohan")
      assert_not_equal loc1.object_id, loc2.object_id # Ensure we've got different instances
      assert loc1 == loc2
    end

    should "not consider instances with different slugs as ==" do
      loc1 = WorldLocation.find("rohan")
      loc2 = WorldLocation.find("gondor")
      assert_not loc1 == loc2
    end

    should "not consider instance of a different class as ==" do
      loc1 = WorldLocation.find("rohan")
      loc2 = OpenStruct.new(slug: "rohan")
      assert_not loc1 == loc2
    end
  end

  context "accessing attributes" do
    setup do
      stub_worldwide_api_has_location("rohan")
      @location = WorldLocation.find("rohan")
    end

    should "allow accessing required top-level attributes" do
      assert_equal "Rohan", @location.title
      assert_equal "Rohan", @location.name # alias for title
      assert_equal "rohan", @location.slug
    end

    should "allow accessing required details attributes" do
      assert_equal "rohan", @location.slug
    end
  end

  context "organisations" do
    setup do
      stub_worldwide_api_has_location("rohan")
      @location = WorldLocation.find("rohan")
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
        assert_nil @location.fco_organisation
      end

      should "return the first if multiple match" do
        WorldwideOrganisation.stubs(:for_location).once.returns([@org1, @org2, @org3, @org4])
        assert_equal @org2, @location.fco_organisation
      end
    end
  end

  context "england_coronavirus_travel" do
    setup do
      @future_status_date = "2022-02-20T:02:00.000+00:00"
      WorldLocation.stubs(:travel_rules).returns({
        "results" => [
          {
            "title" => "Italy",
            "details" => {
              "slug" => "italy",
            },
            "england_coronavirus_travel" => [
              {
                "covid_status" => "red",
                "covid_status_applies_at" => "2021-12-20T:02:00.000+00:00",
              },
              {
                "covid_status" => "not_red",
                "covid_status_applies_at" => @future_status_date,
              },
            ],
          },
        ],
      })
      travel_to("2022-01-01")
    end

    context "covid statuses exist" do
      setup do
        stub_worldwide_api_has_location("italy")
        @location = WorldLocation.find("italy")
      end

      should "find the current covid status for a location" do
        assert_equal "red", @location.covid_status
      end

      should "find the next covid status for a location" do
        assert_equal "not_red", @location.next_covid_status
      end

      should "find the next covid status applies at date for a location" do
        assert_equal Time.zone.parse(@future_status_date), @location.next_covid_status_applies_at
      end

      should "return 'true' for on_red_list? if covid status is 'red'" do
        assert @location.on_red_list?
      end
    end

    context "covid statuses do not exist" do
      setup do
        stub_worldwide_api_has_location("spain")
        @location = WorldLocation.find("spain")
      end

      should "return covid status of nil if covid statuses unknown for location" do
        assert_nil @location.covid_status
      end

      should "return a next covid status of nil if covid statuses unknown for location" do
        assert_nil @location.next_covid_status
      end

      should "return a next covid status date of nil if covid statuses unknown for location" do
        assert_nil @location.next_covid_status_applies_at
      end

      should "return 'false' for on_red_list? if covid status is not known" do
        assert_not @location.on_red_list?
      end
    end
  end
end
