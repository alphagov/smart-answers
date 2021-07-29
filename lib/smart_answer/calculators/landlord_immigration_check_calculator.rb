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
      # response = GdsApi.imminence.areas_for_postcode(postcode)
      # response_status = response.dig("_response_info", "status")
      #
      # case response_status
      # when "ok"
      #   response["results"]
      # when 404
      #   raise invalid_postcode_error
      # else
      #   raise failed_postcode_lookup_error(response_status, postcode)
      # end
      [{"name"=>"Anston & Woodsetts",
        "country_name"=>"England",
        "type"=>"MTW",
        "codes"=>{"gss"=>"E05012993"}},
      {"name"=>"Rotherham Metropolitan Borough Council",
       "country_name"=>"England",
       "type"=>"MTD",
       "codes"=>{"gss"=>"E08000018"}},
      {"name"=>"Rother Valley",
       "country_name"=>"England",
       "type"=>"WMC",
       "codes"=>{"gss"=>"E14000903"}},
      {"name"=>"Yorkshire and the Humber English Region",
       "country_name"=>"England",
       "type"=>"EUR",
       "codes"=>{"gss"=>"E12000003"}}]
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
