class FlowContentItemWithoutStartPage < FlowContentItem
  CONTENT_ID_FOR_BASE_PATH = {
    "/part-year-profit-tax-credits/y" => "22e523d6-a153-4f66-b0fa-53ec46bcd61f"
  }.freeze

  def payload
    {
      base_path: base_path,
      title: flow_presenter.title,
      details: {
          external_related_links: external_related_links
      },
      schema_name: 'generic_with_external_related_links',
      document_type: 'smart_answer',
      publishing_app: 'smartanswers',
      rendering_app: 'smartanswers',
      locale: 'en',
      routes: routes
    }
  end

  def content_id
    CONTENT_ID_FOR_BASE_PATH[base_path]
  end
end
