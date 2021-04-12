class StartPageContentItem
  attr_reader :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def payload
    {
      base_path: base_path,
      title: flow_presenter.title,
      description: flow_presenter.meta_description,
      update_type: "minor",
      details: {
        introductory_paragraph: [
          {
            content: flow_presenter.start_node.body,
            content_type: "text/govspeak",
          },
        ],
        more_information: [
          content: flow_presenter.start_node.post_body,
          content_type: "text/govspeak",
        ],
        transaction_start_link: flow_presenter.start_page_link,
        start_button_text: flow_presenter.start_node.start_button_text,
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
    "/#{flow_presenter.name}"
  end
end
