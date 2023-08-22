module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/childcare-costs-for-tax-credits" => "https://surveys.publishing.service.gov.uk/s/4J4QD4/",
    }.freeze

    def survey_url(path)
      landing_page?(path) && SURVEY_URLS[base_path]
    end

  private

    def base_path
      "/#{@flow_presenter.name}"
    end

    def landing_page?(current_path)
      base_path == current_path
    end
  end
end
