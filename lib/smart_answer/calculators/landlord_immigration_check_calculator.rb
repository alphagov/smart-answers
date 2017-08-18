module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculator
    include ActiveModel::Model

    attr_accessor :postcode, :nationality

    def rules_apply?
      countries_for_postcode.include?('England')
    end

    def countries_for_postcode
      areas_for_postcode.map { |results| results["country_name"] }.uniq
    end

    def areas_for_postcode
      response = Services.imminence_api.areas_for_postcode(postcode)

      case response.dig("_response_info", "status")
      when "ok"
        response["results"]
      when 404
        raise postcode_lookup_exception(:error_postcode_invalid)
      else
        raise postcode_lookup_exception(:error_postcode_lookup_failed)
      end
    end

    def postcode_lookup_exception(error)
      SmartAnswer::BaseStateTransitionError.new(error.to_s)
    end

    def from_somewhere_else?
      @nationality == "somewhere-else"
    end
  end
end
