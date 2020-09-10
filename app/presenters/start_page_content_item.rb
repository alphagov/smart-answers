class StartPageContentItem
  attr_reader :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def payload
    {
      base_path: base_path,
      title: flow_presenter.title,
      description: flow_presenter.description,
      update_type: "minor",
      details: {
        external_related_links: flow_presenter.external_related_links,
        introductory_paragraph: [
          {
            content: flow_presenter.start_page_body,
            content_type: "text/govspeak",
          },
        ],
        more_information: [
          content: flow_presenter.start_page_post_body,
          content_type: "text/govspeak",
        ],
        transaction_start_link: base_path + "/y",
        start_button_text: flow_presenter.start_page_button_text,
        hidden_search_terms: flow_presenter.flows_content,
      },
      schema_name: "transaction",
      document_type: "transaction",
      publishing_app: "smartanswers",
      rendering_app: "frontend",
      locale: "en",
      public_updated_at: Time.zone.now.iso8601,
      routes: [{ type: "exact", path: base_path }],
    }
  end

  def content_id
    flow_presenter.start_page_content_id
  end

private

  def base_path
    "/" + flow_presenter.slug
  end
end
