class FlowContentItem
  attr_reader :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def payload
    {
      base_path: flow_presenter.start_page_link,
      title: flow_presenter.title,
      update_type: "minor",
      details: {},
      schema_name: "generic",
      document_type: "smart_answer",
      publishing_app: "smartanswers",
      rendering_app: "smartanswers",
      locale: "en",
      public_updated_at: Time.zone.now.iso8601,
      routes: [{ type: "prefix", path: flow_presenter.start_page_link }],
    }
  end

  def content_id
    flow_presenter.flow_content_id
  end
end
