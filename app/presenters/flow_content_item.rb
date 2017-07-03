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
      schema_name: 'generic_with_external_related_links',
      document_type: 'smart_answer',
      publishing_app: 'smartanswers',
      rendering_app: 'smartanswers',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: routes
    }
  end

  def content_id
    flow_presenter.start_page_content_id
  end

private

  def routes
    [
      { type: 'prefix', path: base_path },
      { type: 'exact', path: json_path }
    ]
  end

  def base_path
    '/' + flow_presenter.slug
  end

  def json_path
    "#{base_path}.json"
  end

  def external_related_links
    flow_presenter.external_related_links
  end
end
