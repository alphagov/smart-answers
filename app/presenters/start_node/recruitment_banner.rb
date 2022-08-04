module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/maternity-paternity-pay-leave" => "https://GDSUserResearch.optimalworkshop.com/treejack/b3cu012d",
      "/check-uk-visa" => "https://surveys.publishing.service.gov.uk/s/0DZCPX/",
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
