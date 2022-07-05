module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/maternity-paternity-pay-leave" => "https://GDSUserResearch.optimalworkshop.com/treejack/61ec38b742396bc23d00104953ffb17d",
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
