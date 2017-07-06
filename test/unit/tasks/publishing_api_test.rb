require 'test_helper'

class PublisingApiRakeTest < ActiveSupport::TestCase
  context "publishing_api:publish_start_page_as_transaction rake task" do
    setup do
      Rake::Task["publishing_api:publish_start_page_as_transaction"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke
      end

      assert_equal "Missing content id parameter", exception.message
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke("content-id", nil)
      end

      assert_equal "Missing base path parameter", exception.message
    end

    should "raise exception when destination isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke(
          "content-id",
          "/base-path",
          nil
        )
      end

      assert_equal "Missing publishing_app parameter", exception.message
    end

    should "raise exception when title isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke(
          "content-id",
          "/base-path",
          "publisher",
          nil
        )
      end

      assert_equal "Missing title parameter", exception.message
    end

    should "raise exception when content isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke(
          "content-id",
          "/base-path",
          "publisher",
          "Title",
          nil
        )
      end

      assert_equal "Missing content parameter", exception.message
    end

    should "raise exception when link isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke(
          "content-id",
          "/base-path",
          "publisher",
          "Title",
          "Sample Content",
          nil
        )
      end

      assert_equal "Missing link parameter", exception.message
    end

    should "invoke the reserve_path_for_publishing_app and publish_transaction_start_page from ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance

      content_item_publisher_mock.stubs(:reserve_path_for_publishing_app).returns(nil)
      content_item_publisher_mock.stubs(:publish_transaction_start_page)
        .returns(nil)

      content_item_publisher_mock.expects(:publish_transaction_start_page).once
      content_item_publisher_mock.expects(:reserve_path_for_publishing_app).once

      Rake::Task["publishing_api:publish_start_page_as_transaction"].invoke(
        "content-id",
        "/base-path",
        "publisher",
        "Title",
        "Sample content",
        "/path/to/smartnanswer"
      )
    end
  end
end
