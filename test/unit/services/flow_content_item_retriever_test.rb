require "test_helper"

class FlowContentItemRetrieverTest < ActiveSupport::TestCase
  setup do
    @slug = "example-smart-answer"
    @content_store_response = {
      base_path: "/#{@slug}/y",
      content_id: "c22fa786-6c0d-4e38-a82f-c8ca341f9260",
      title: "Example Smart Answer",
      links: {
        organisations: [
          {
            base_path: "path/to/an/organisations/content",
            content_id: "3fb96b2b-8c29-43dc-83c9-489866d7cc38",
            document_type: "organisations"
          }
        ]
      }
    }.with_indifferent_access
    @request_url = "https://content-store.test.gov.uk/content/#{@slug}/y"
  end

  context "fetch" do
    should "make request to content store for content item" do
      response = { status: 200, body: {}.to_json }
      content_store_request = stub_request(:get, @request_url).to_return(response)

      FlowContentItemRetriever.fetch(@slug)

      assert_requested content_store_request
    end

    context "when content item exist" do
      should "return content item from content store" do
        response = { status: 200, body: @content_store_response.to_json }
        stub_request(:get, @request_url).to_return(response)

        content_item = FlowContentItemRetriever.fetch(@slug)

        assert_equal content_item, @content_store_response
      end
    end

    context "when content item can't be found" do
      should "return empty content item hash" do
        response = { status: 404, body: {}.to_json }
        stub_request(:get, @request_url).to_return(response)

        assert_equal FlowContentItemRetriever.fetch(@slug), {}
      end
    end

    context "when content item can't be found" do
      should "return empty content item hash" do
        response = { status: 410, body: {}.to_json }
        stub_request(:get, @request_url).to_return(response)

        assert_equal FlowContentItemRetriever.fetch(@slug), {}
      end
    end
  end
end
