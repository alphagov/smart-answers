module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculator
    attr_reader :postcode

    def initialize(postcode)
      @postcode = postcode
    end

    def rules_apply?
      countries_for_postcode.include?('England')
    end

    def countries_for_postcode
      areas_for_postcode.map { |a| a['country_name'] }.uniq
    end

    def areas_for_postcode
      Services.imminence_api.areas_for_postcode(postcode).results
    end
  end
end
