require_relative "../test_helper"

module SmartAnswer
  class ContentBlockTest < ActiveSupport::TestCase
    setup do
      @embed_code = "{{embed:content_block_something:some-slug}}"
      @reference = stub_content_block_reference(@embed_code)
      content_id = "some-content-id"
      title = "Some title"
      details = { "some_key" => "some_value" }
      stub_publishing_api_response(
        reference: @reference,
        content_id:,
        title:,
        details:,
      )
      @content_block = stub_content_block(
        reference: @reference,
        content_id:,
        title:,
        details:,
      )
    end

    test "it renders a block of content when given an embed code" do
      assert_equal @content_block.render, SmartAnswer::ContentBlock.new(@embed_code).render
    end

  private

    def stub_content_block_reference(embed_code)
      reference = stub("content_block_reference", document_type: "content_block_something", identifier: "some-slug")
      ContentBlockTools::ContentBlockReference.expects(:from_string).with(embed_code).returns(reference)
      reference
    end

    def stub_publishing_api_response(reference:, content_id:, title:, details:)
      publishing_api = stub("publishing_api")
      api_response = {
        "results" => [
          {
            "content_id" => content_id,
            "title" => title,
            "details" => details,
          },
        ],
      }

      GdsApi.expects(:publishing_api).returns(publishing_api)
      publishing_api.expects(:get_content_items).with(
        document_type: reference.document_type,
        content_id_aliases: [reference.identifier],
      ).returns(api_response)
    end

    def stub_content_block(reference:, content_id:, title:, details:)
      content_block = stub("content_block", render: "some content")
      ContentBlockTools::ContentBlock.expects(:new).with(
        content_id:,
        title:,
        document_type: reference.document_type,
        details:,
        embed_code: @embed_code,
      ).returns(content_block)
      content_block
    end
  end
end
