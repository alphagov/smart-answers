require 'test_helper'

class ContentItemPublisherTest < ActiveSupport::TestCase
  setup do
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
  end

  context "#publish" do
    should "send message to create_and_publish_transaction_start_page if smart_answer start page is a transaction start page" do
      presenters = [mock("FlowRegistrationPresenter", transaction_start_page?: true)]

      ContentItemPublisher.any_instance.expects(:create_and_publish_transaction_start_page).once

      ContentItemPublisher.new.publish(presenters)
    end

    should "send content item to publishing_api" do
      draft_request = stub_request(:put, "https://publishing-api.test.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685")
      publishing_request = stub_request(:post, "https://publishing-api.test.gov.uk/v2/content/3e6f33b8-0723-4dd5-94a2-cab06f23a685/publish")

      presenter = FlowRegistrationPresenter.new(stub('flow', name: 'bridge-of-death', content_id: '3e6f33b8-0723-4dd5-94a2-cab06f23a685', external_related_links: nil, transaction_start_page?: false))

      ContentItemPublisher.new.publish([presenter])

      assert_requested draft_request
      assert_requested publishing_request
    end
  end

  context "#unpublish" do
    should 'send unpublish request to content store' do
      unpublish_url = 'https://publishing-api.test.gov.uk/v2/content/content-id/unpublish'
      unpublish_request = stub_request(:post, unpublish_url)

      ContentItemPublisher.new.unpublish('content-id')

      assert_requested unpublish_request
    end

    should 'raise exception if content_id has not been supplied' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.unpublish(nil)
      end

      assert_equal "Content id has not been supplied", exception.message
    end
  end

  context "#publish_redirect" do
    setup do
      SecureRandom.stubs(:uuid).returns('content-id')
      create_url = 'https://publishing-api.test.gov.uk/v2/content/content-id'
      @create_request = stub_request(:put, create_url)
      publish_url = 'https://publishing-api.test.gov.uk/v2/content/content-id/publish'
      @publish_request = stub_request(:post, publish_url)
    end

    should 'send a redirect and publish request to publishing-api' do
      ContentItemPublisher.new.publish_redirect('/path', '/destination-path')

      assert_requested @create_request
      assert_requested @publish_request
    end

    should 'raise exception and not attempt publishing and router requests, when create request fails' do
      GdsApi::Response.any_instance.stubs(:code).returns(500)
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_redirect('/path', '/destination-path')
      end

      assert_equal "This content item has not been created", exception.message
      assert_requested @create_request
      assert_not_requested @publish_request
    end

    should 'raises exception if destination is not defined' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_redirect('/path', nil)
      end

      assert_equal "The destination or path isn't defined", exception.message
    end

    should 'raises exception if path is not defined' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_redirect(nil, '/destination-path')
      end

      assert_equal "The destination or path isn't defined", exception.message
    end
  end

  context "#remove_smart_answer_from_search" do
    should 'raise exception if base_path is not supplied' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.remove_smart_answer_from_search(nil)
      end

      assert_equal "The base_path isn't supplied", exception.message
    end

    should 'send remove content request to rummager' do
      delete_url = 'https://rummager.test.gov.uk/content?link=/base-path'
      delete_request = stub_request(:delete, delete_url)

      ContentItemPublisher.new.remove_smart_answer_from_search('/base-path')

      assert_requested delete_request
    end
  end

  context "#reserve_path_for_publishing_app" do
    should 'raise exception if base_path is not supplied' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.reserve_path_for_publishing_app(nil, "publisher")
      end

      assert_equal "The destination or path isn't supplied", exception.message
    end

    should 'raise exception if publishing_app is not supplied' do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.reserve_path_for_publishing_app("/base_path", nil)
      end

      assert_equal "The destination or path isn't supplied", exception.message
    end

    should 'send a base_path publishing_app reservation request' do
      reservation_url = 'https://publishing-api.test.gov.uk/paths//base_path'
      reservation_request = stub_request(:put, reservation_url)

      ContentItemPublisher.new.reserve_path_for_publishing_app('/base_path', 'publisher')

      assert_requested reservation_request
    end
  end

  context "#create_and_publish_transaction_start_page" do
    should "send create and publish transaction to publishing-api" do
      reservation_url = 'https://publishing-api.test.gov.uk/paths//smart-answer-slug'
      reservation_request = stub_request(:put, reservation_url)
      create_url = "https://publishing-api.test.gov.uk/v2/content/content_id"
      create_request = stub_request(:put, create_url)
      publish_url = "https://publishing-api.test.gov.uk/v2/content/content_id/publish"
      publish_request = stub_request(:post, publish_url)

      flow_create_url = "https://publishing-api.test.gov.uk/v2/content/flow_content_id"
      flow_create_request = stub_request(:put, flow_create_url)
      flow_publish_url = "https://publishing-api.test.gov.uk/v2/content/flow_content_id/publish"
      flow_publish_request = stub_request(:post, flow_publish_url)

      flow_presenter = mock("FlowRegistrationPresenter", slug: "smart-answer-slug", title: "Title", body: "Sample body content")
      content_item = mock("FlowContentItem", flow_presenter: flow_presenter, content_id: "content_id", flow_content_id: "flow_content_id", payload: {})

      ContentItemPublisher.new.create_and_publish_transaction_start_page(content_item)

      assert_requested reservation_request
      assert_requested create_request
      assert_requested publish_request
      assert_requested flow_create_request
      assert_requested flow_publish_request
    end
  end

  context "#publish_transaction" do
    setup do
      SecureRandom.stubs(:uuid).returns('content-id')
      create_url = "https://publishing-api.test.gov.uk/v2/content/content-id"
      @create_request = stub_request(:put, create_url)
      publish_url = "https://publishing-api.test.gov.uk/v2/content/content-id/publish"
      @publish_request = stub_request(:post, publish_url)
    end

    should "raise exception if base_path is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          nil,
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "https://smaple.gov.uk/path/to/somewhere"
        )
      end

      assert_equal "The base path isn't supplied", exception.message
    end

    should "raise exception if publishing_app is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          "/base-path",
          publishing_app: nil,
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "https://smaple.gov.uk/path/to/somewhere"
        )
      end

      assert_equal "The publishing_app isn't supplied", exception.message
    end

    should "raise exception if title is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          "/base-path",
          publishing_app: "publisher",
          title: nil,
          content: "Sample transaction content",
          link: "https://smaple.gov.uk/path/to/somewhere"
        )
      end

      assert_equal "The title isn't supplied", exception.message
    end

    should "raise exception if content is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: nil,
          link: "https://smaple.gov.uk/path/to/somewhere"
        )
      end

      assert_equal "The content isn't supplied", exception.message
    end

    should "raise exception if link is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: nil
        )
      end

      assert_equal "The link isn't supplied", exception.message
    end

    should "send publish transaction request to publishing-api" do
      ContentItemPublisher.new.publish_transaction(
        "/base-path",
        publishing_app: "publisher",
        title: "Sample transaction title",
        content: "Sample transaction content",
        link: "https://smaple.gov.uk/path/to/somewhere"
      )

      assert_requested @create_request
      assert_requested @publish_request
    end

    should "raise exception and not attempt publishing transaction when create request fails" do
      GdsApi::Response.any_instance.stubs(:code).returns(500)
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction(
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "https://smaple.gov.uk/path/to/somewhere"
        )
      end

      assert_equal "This content item has not been created", exception.message
      assert_requested @create_request
      assert_not_requested @publish_request
    end
  end

  context "#publish_transaction_start_page" do
    setup do
      SecureRandom.stubs(:uuid).returns('content-id')
      create_url = "https://publishing-api.test.gov.uk/v2/content/content-id"
      @create_request = stub_request(:put, create_url)
      publish_url = "https://publishing-api.test.gov.uk/v2/content/content-id/publish"
      @publish_request = stub_request(:post, publish_url)
    end

    should "raise exception if content id is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          nil,
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "/path/to/smartanswers/y"
        )
      end

      assert_equal "The content id isn't supplied", exception.message
    end

    should "raise exception if base path is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          "content_id",
          nil,
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "/path/to/smartanswers/y"
        )
      end

      assert_equal "The base path isn't supplied", exception.message
    end

    should "raise exception if publishing_app is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          "content_id",
          "/base-path",
          publishing_app: nil,
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: "/path/to/smartanswers/y"
        )
      end

      assert_equal "The publishing_app isn't supplied", exception.message
    end

    should "raise exception if title is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          "content_id",
          "/base-path",
          publishing_app: "publisher",
          title: nil,
          content: "Sample transaction content",
          link: "/path/to/smartanswers/y"
        )
      end

      assert_equal "The title isn't supplied", exception.message
    end

    should "raise exception if content is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          "content_id",
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: nil,
          link: "/path/to/smartanswers/y"
        )
      end

      assert_equal "The content isn't supplied", exception.message
    end

    should "raise exception if link is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_transaction_start_page(
          "content_id",
          "/base-path",
          publishing_app: "publisher",
          title: "Sample transaction title",
          content: "Sample transaction content",
          link: nil
        )
      end

      assert_equal "The link isn't supplied", exception.message
    end

    should "send publish transaction message to publish_transaction_start_page_via_publishing_api" do
      ContentItemPublisher.any_instance.expects(:publish_transaction_start_page_via_publishing_api).once

      ContentItemPublisher.new.publish_transaction_start_page(
        "content-id",
        "/base-path",
        publishing_app: "publisher",
        title: "Sample transaction title",
        content: "Sample transaction content",
        link: "/path/to/smartanswers/y"
      )
    end

    should "send publish transaction request to publish_transaction_start_page_via_publishing_api" do
      ContentItemPublisher.new.publish_transaction_start_page(
        "content-id",
        "/base-path",
        publishing_app: "publisher",
        title: "Sample transaction title",
        content: "Sample transaction content",
        link: "/path/to/smartanswers/y"
      )

      assert_requested @create_request
      assert_requested @publish_request
    end
  end

  context "#publish_answer" do
    setup do
      SecureRandom.stubs(:uuid).returns('content-id')
      create_url = "https://publishing-api.test.gov.uk/v2/content/content-id"
      @create_request = stub_request(:put, create_url)
      publish_url = "https://publishing-api.test.gov.uk/v2/content/content-id/publish"
      @publish_request = stub_request(:post, publish_url)
    end

    should "send publish answer request to publishing-api" do
      ContentItemPublisher.new.publish_answer(
        "/base-path",
        publishing_app: "publisher",
        title: "Sample answer title",
        content: "Sample answer content"
      )

      assert_requested @create_request
      assert_requested @publish_request
    end

    should "raise exception and not attempt publishing answer when create request fails" do
      GdsApi::Response.any_instance.stubs(:code).returns(500)
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_answer(
          "/base-path",
          publishing_app: "publisher",
          title: "Sample answer title",
          content: "Sample answer content"
        )
      end

      assert_equal "This content item has not been created", exception.message
      assert_requested @create_request
      assert_not_requested @publish_request
    end

    should "raise exception if base_path is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_answer(
          nil,
          publishing_app: "publisher",
          title: "Sample answer title",
          content: "Sample answer content"
        )
      end

      assert_equal "The base path isn't supplied", exception.message
    end

    should "raise exception if publishing_app is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_answer(
          "/base-path",
          publishing_app: nil,
          title: "Sample answer title",
          content: "Sample answer content"
        )
      end

      assert_equal "The publishing_app isn't supplied", exception.message
    end

    should "raise exception if title is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_answer(
          "/base-path",
          publishing_app: "publisher",
          title: nil,
          content: "Sample answer content"
        )
      end

      assert_equal "The title isn't supplied", exception.message
    end

    should "raise exception if content is not supplied" do
      exception = assert_raises(RuntimeError) do
        ContentItemPublisher.new.publish_answer(
          "/base-path",
          publishing_app: "publisher",
          title: "Sample answer title",
          content: nil
        )
      end

      assert_equal "The content isn't supplied", exception.message
    end
  end
end
