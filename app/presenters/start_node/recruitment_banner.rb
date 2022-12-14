module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/state-pension-age" => "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a",
      "/child-benefit-tax-calculator" => "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a",
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
