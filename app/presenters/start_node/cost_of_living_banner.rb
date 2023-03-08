module StartNode
  module CostOfLivingBanner
    COST_OF_LIVING_SURVEY_URL = "https://s.userzoom.com/m/MSBDMTQ3MVM0NCAg".freeze

    SURVEY_URL_MAPPINGS = {
      "/check-benefits-financial-support" => COST_OF_LIVING_SURVEY_URL,
    }.freeze

    def survey_url
      SURVEY_URL_MAPPINGS[base_path]
    end

  private

    def base_path
      "/#{@flow_presenter.name}"
    end
  end
end
