module StartNode
  module UserResearchBanner
    SURVEY_URLS = {
      "/check-benefits-financial-support" => "https://gdsuserresearch.optimalworkshop.com/treejack/f49b8c01521bf45bd0a519fe02f5f913",
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
