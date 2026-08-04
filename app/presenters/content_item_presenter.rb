class ContentItemPresenter
  include ContentItemHelper

  attr_reader :flow

  def initialize(flow)
    @flow = flow
  end

  def payload
    {
      base_path:,
      title: start_node_presenter.title,
      description: start_node_presenter.meta_description,
      update_type: "minor",
      details: {
        hidden_search_terms: extract_flow_content(flow, start_node_presenter),
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

private

  def start_node_presenter
    @start_node_presenter ||= flow.start_node.presenter
  end

  def base_path
    "/#{flow.name}"
  end
end
