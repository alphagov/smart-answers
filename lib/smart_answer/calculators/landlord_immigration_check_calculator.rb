module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculator

    VALID_COUNTRIES = %w( England )

    attr_reader :postcode

    def initialize(postcode)
      @postcode = postcode
    end

    def included_country?
      postcode_within?(VALID_COUNTRIES, 'country_name')
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
