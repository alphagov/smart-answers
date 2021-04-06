class ContentItem
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
        hidden_search_terms: flow_presenter.flows_content,
      },
      schema_name: "smart_answer",
      document_type: "smart_answer",
      publishing_app: "smartanswers",
      rendering_app: "smartanswers",
      locale: "en",
      public_updated_at: Time.zone.now.iso8601,
      routes: [
        { type: "prefix", path: base_path },
      ],
    }
  end

  def content_id
    flow_presenter.content_id
  end

private

  def base_path
    "/#{flow_presenter.name}"
  end
end
