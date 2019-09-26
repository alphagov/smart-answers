module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculator
    include ActiveModel::Model

    attr_accessor :postcode, :nationality

    def rules_apply?
      countries_for_postcode.include?("England")
    end

    def countries_for_postcode
      areas_for_postcode.map { |results| results["country_name"] }.uniq
    end

    def areas_for_postcode
      response = Services.imminence_api.areas_for_postcode(postcode)
      response_status = response.dig("_response_info", "status")

      case response_status
      when "ok"
        response["results"]
      when 404
        raise invalid_postcode_error
      else
        raise failed_postcode_lookup_error(response_status, postcode)
      end
    end

    def invalid_postcode_error
      SmartAnswer::BaseStateTransitionError.new("error_postcode_invalid")
    end

    def failed_postcode_lookup_error(status, postcode)
      SmartAnswer::LoggedError.new(
        "error_postcode_lookup_failed",
        "Got '#{status}' status looking up postcode '#{postcode}'",
      )
    end

    def from_somewhere_else?
      @nationality == "somewhere-else"
    end
  end
end
