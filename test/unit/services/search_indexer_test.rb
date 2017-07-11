require 'test_helper'

class SearchIndexerTest < ActiveSupport::TestCase
  def test_indexing_to_rummager
    flow_presenter = stub(
      slug: 'student-finance-forms',
      title: 'Student finance forms',
      description: 'Download Student Finance',
      indexable_content: 'Download student finance content',
      start_page_content_id: '67764435-e8ed-4700-a657-2e0432cb1f5b'
    )
    Services.rummager.expects(:add_document).with(
      'edition',
      "/#{flow_presenter.slug}",
      content_id: flow_presenter.start_page_content_id,
      rendering_app:  "smartanswers",
      publishing_app: "smartanswers",
      format: "smart-answer",
      title: flow_presenter.title,
      description: flow_presenter.description,
      indexable_content: flow_presenter.indexable_content,
      link: "/#{flow_presenter.slug}",
      content_store_document_type: 'smart_answer',
    )

    SearchIndexer.call(flow_presenter)
  end
end
