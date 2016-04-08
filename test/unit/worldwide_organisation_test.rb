require_relative '../test_helper'

class WorldwideOrganisationTest < ActiveSupport::TestCase
  context '.for_location' do
    should 'instantiates WorldwideOrganisation objects using data from the API' do
      organisations_data = [
        OpenStruct.new(title: 'organisation-1-title'),
        OpenStruct.new(title: 'organisation-2-title')
      ]
      worldwide_api = stub('worldwide-api')
      worldwide_api.stubs(:organisations_for_world_location).with('location-slug').returns(organisations_data)
      Services.stubs(:worldwide_api).returns(worldwide_api)

      worldwide_organisations = WorldwideOrganisation.for_location('location-slug')

      assert_equal 2, worldwide_organisations.count
      assert worldwide_organisations.first.is_a?(WorldwideOrganisation)
      assert worldwide_organisations.last.is_a?(WorldwideOrganisation)
      assert_equal ['organisation-1-title', 'organisation-2-title'], worldwide_organisations.map(&:title)
    end
  end

  context "fco_sponsored?" do
    should "return true for an organisation sponsored by the FCO" do
      organisation_data = OpenStruct.new(
        sponsors: [
          OpenStruct.new(
            details: OpenStruct.new(acronym: 'FCO')
          )
        ]
      )
      worldwide_organisation = WorldwideOrganisation.new(organisation_data)

      assert_equal true, worldwide_organisation.fco_sponsored?
    end

    should "return false for an organisation not sponsored by the FCO" do
      organisation_data = OpenStruct.new(sponsors: [])
      worldwide_organisation = WorldwideOrganisation.new(organisation_data)

      assert_equal false, worldwide_organisation.fco_sponsored?
    end
  end

  context "offices with services" do
    should "find offices with service" do
      organisation_data = OpenStruct.new(
        offices: OpenStruct.new(
          main: OpenStruct.new(
            title: 'main-office',
            services: []
          ),
          other: [
            OpenStruct.new(
              title: 'other-office-1',
              services: [OpenStruct.new(title: 'service-offered')]
            ),
            OpenStruct.new(
              title: 'other-office-2',
              services: [OpenStruct.new(title: 'service-offered')]
            )
          ]
        )
      )
      organisation = WorldwideOrganisation.new(organisation_data)

      matches = organisation.offices_with_service('service-offered')
      assert_equal 2, matches.length, "Wrong number of offices matched"
      assert_equal 'other-office-1', matches[0].title
      assert_equal 'other-office-2', matches[1].title
    end

    should "fallback to main office" do
      organisation_data = OpenStruct.new(
        offices: OpenStruct.new(
          main: OpenStruct.new(
            title: 'main-office',
            services: []
          ),
          other: []
        )
      )
      organisation = WorldwideOrganisation.new(organisation_data)

      matches = organisation.offices_with_service('obscure-service')
      assert_equal 1, matches.length, "Wrong number of offices matched"
      assert_equal 'main-office', matches[0].title
    end

    should "return empty array if no offices" do
      organisation_data = OpenStruct.new(
        offices: OpenStruct.new(
          main: nil,
          other: []
        )
      )
      organisation = WorldwideOrganisation.new(organisation_data)

      matches = organisation.offices_with_service('service-name')
      assert_equal [], matches
    end
  end

  context "attribute accessors" do
    setup do
      organisation_data = OpenStruct.new(
        title: 'organisation-title',
        web_url: 'organisation-web-url',
        offices: OpenStruct.new(
          main: OpenStruct.new(
            title: 'main-office-title'
          ),
          other: [
            OpenStruct.new(
              title: 'other-office-title'
            )
          ]
        )
      )
      @organisation = WorldwideOrganisation.new(organisation_data)
    end

    should "allow accessing required top-level attributes" do
      assert_equal 'organisation-title', @organisation.title
    end

    context "accessing office details" do
      should "allow accessing office details" do
        assert_equal 'main-office-title', @organisation.offices.main.title
      end

      should "have shortcut accessor for main office" do
        assert_equal "main-office-title", @organisation.main_office.title
      end

      should "have shortcut accessor for other offices" do
        assert_equal 'other-office-title', @organisation.other_offices.first.title
      end

      should "have an accessor for all offices" do
        assert_equal 2, @organisation.all_offices.size
        assert_equal ['main-office-title', 'other-office-title'], @organisation.all_offices.map(&:title)
      end

      should "have an accessor for the URL" do
        assert_equal 'organisation-web-url', @organisation.web_url
      end
    end
  end
end
