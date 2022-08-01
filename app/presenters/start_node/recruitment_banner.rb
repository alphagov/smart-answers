module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/maternity-paternity-pay-leave" => "https://GDSUserResearch.optimalworkshop.com/treejack/834dm2s6",
    }.freeze

    def recruitment_survey_url
      SURVEY_URLS[base_path]
    end

  private

    def base_path
      "/#{@flow_presenter.name}"
    end
  end
end
