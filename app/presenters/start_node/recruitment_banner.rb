module StartNode
  module RecruitmentBanner
    SURVERY_URL = "https://surveys.publishing.service.gov.uk/s/SNFVW1/".freeze
    SURVEY_URLS = {
      "/maternity-paternity-calculator" => SURVERY_URL,
      "/calculate-statutory-sick-pay" => SURVERY_URL,
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
