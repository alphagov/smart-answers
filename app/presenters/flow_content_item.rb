class FlowContentItem
  attr_reader :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def payload
    {
      title: flow_presenter.title,
      content_id: flow_presenter.content_id,
      format: 'placeholder_smart_answer',
      publishing_app: 'smartanswers',
      rendering_app: 'smartanswers',
      update_type: 'minor',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'exact', path: base_path }
      ]
    }
  end

  def base_path
    '/' + flow_presenter.slug
  end
end
