class SearchIndexer
  attr_reader :flow_presenter
  delegate :slug, to: :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def self.call(flow_presenter)
    new(flow_presenter).call
  end

  def call
    Services.rummager.add_document(document_type, document_id, payload)
  end

private

  def document_type
    'edition'
  end

  def document_id
    "/#{slug}"
  end

  def payload
    SearchPayloadPresenter.call(flow_presenter)
  end
end
