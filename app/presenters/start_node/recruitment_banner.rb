module StartNode
  module RecruitmentBanner
    BRAND_SURVERY_URL = "https://surveys.publishing.service.gov.uk/s/5G06FO/".freeze
    SURVEY_URLS = {
      "/check-uk-visa" => BRAND_SURVERY_URL,
      "/state-pension-age" => BRAND_SURVERY_URL,
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
