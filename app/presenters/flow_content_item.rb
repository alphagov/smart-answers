class FlowContentItem
  attr_reader :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def payload
    {
      base_path: base_path,
      title: flow_presenter.title,
      details: {
          external_related_links: external_related_links
      },
      schema_name: 'placeholder_smart_answer',
      document_type: 'smartanswer_document',
      publishing_app: 'smartanswers',
      rendering_app: 'smartanswers',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'exact', path: base_path }
      ]
    }
  end

  def content_id
    flow_presenter.content_id
  end

private

  def base_path
    '/' + flow_presenter.slug
  end

  def external_related_links
    flow_presenter.external_related_links
  end
end
