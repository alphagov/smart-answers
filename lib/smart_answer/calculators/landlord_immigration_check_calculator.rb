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

      if response.dig("_response_info", "status") == "ok"
        response["results"]
      else
        report_error(response)
        raise postcode_lookup_exception
      end
    rescue GdsApi::BaseError => e
      report_error(e)
      raise postcode_lookup_exception
    end

    def report_error(hash_or_exception)
      Airbrake.notify(hash_or_exception)
    end

    def postcode_lookup_exception
      SmartAnswer::BaseStateTransitionError.new("error_postcode_lookup_failed")
    end

    def from_somewhere_else?
      @nationality == "somewhere-else"
    end
  end
end
