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

    def self.valid_postcode(postcode)
      response = Services.imminence_api.areas_for_postcode(postcode)
      return false unless response and response.code == 200
      areas = response.to_hash["results"]
      ! areas.find { |a| VALID_BOROUGHS.include?(a["slug"]) }.nil?
    end
  end
end
