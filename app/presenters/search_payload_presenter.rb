class SearchPayloadPresenter
  attr_reader :flow_presenter
  delegate :slug,
           :title,
           :description,
           :indexable_content,
           :start_page_content_id,
           to: :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def self.call(flow_presenter)
    new(flow_presenter).call
  end

  def call
    {
      content_id: start_page_content_id,
      rendering_app: 'smartanswers',
      publishing_app: 'smartanswers',
      format: 'smart-answer',
      title: title,
      description: description,
      indexable_content: indexable_content,
      link: "/#{slug}",
      content_store_document_type: 'smart_answer',
    }
  end
end
