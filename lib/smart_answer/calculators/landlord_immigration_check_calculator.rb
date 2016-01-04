module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculator
    # These MTD areas are currently different on mapit.mysociety.org
    # to preview/production data. They are *-city-council in all cases
    # on Mapit but a mixture of *-borough-council and *-city-council
    # on the internal GOV.UK Mapit instance. The duplication here
    # protects us against the effects of a data update.
    VALID_BOROUGHS = %w(
      birmingham-borough-council
      birmingham-city-council
      dudley-borough-council
      dudley-city-council
      sandwell-borough-council
      sandwell-city-council
      walsall-borough-council
      walsall-city-council
      wolverhampton-city-council
    )

    VALID_COUNTRIES = %w( England )

    attr_reader :postcode

    def initialize(postcode)
      @postcode = postcode
    end

    def included_postcode?
      included_country? || included_borough?
    end

    def included_country?
      postcode_within?(VALID_COUNTRIES, 'country_name')
    end

    def included_borough?
      postcode_within?(VALID_BOROUGHS, 'slug')
    end

    private

    def postcode_within?(included_areas, key_name)
      areas_for_postcode.select {|a| included_areas.include?(a[key_name]) }.any?
    end

    def areas_for_postcode
      response = Services.imminence_api.areas_for_postcode(postcode)
      response.try(:code) == 200 ? response.to_hash["results"] : {}
    end
  end
end
