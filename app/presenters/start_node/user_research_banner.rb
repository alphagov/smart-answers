module StartNode
  module UserResearchBanner
    SURVEY_URLS = {
      "/check-benefits-financial-support" => "https://gdsuserresearch.optimalworkshop.com/treejack/ct80d1d6",
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
