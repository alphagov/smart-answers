require "test_helper"

class RetireSmartAnswerRakeTest < ActiveSupport::TestCase
  context "retire:unpublish_redirect_remove_from_search rake task" do
    setup do
      Rake::Task["retire:unpublish_redirect_remove_from_search"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:unpublish_redirect_remove_from_search"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:unpublish_redirect_remove_from_search"].invoke("content-id", nil)
      end

      assert_equal "Missing base_path parameter", exception.message
    end

    should "raise exception when destination isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:unpublish_redirect_remove_from_search"].invoke(
          "content-id",
          "/base-path",
          nil,
        )
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "invoke the unpublish_with_redirect method from ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance

      content_item_publisher_mock.stubs(:unpublish).returns(nil)

      content_item_publisher_mock
        .expects(:unpublish_with_redirect)
        .with("content-id", "/base-path", "/new-destination")
        .once

      Rake::Task["retire:unpublish_redirect_remove_from_search"].invoke(
        "content-id",
        "/base-path",
        "/new-destination",
      )
    end
  end

  context "retire:unpublish rake task" do
    setup do
      Rake::Task["retire:unpublish"].reenable
      ContentItemPublisher.any_instance.stubs(:unpublish).returns(nil)
    end

    should "raise exception when slug isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:unpublish"].invoke
      end

      assert_equal "Missing content-id parameter", exception.message
    end

    should "invoke the unpublish method on ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:unpublish).with("content-id").once

      Rake::Task["retire:unpublish"].invoke("content-id")
    end
  end

  context "retire:change_owning_application rake task" do
    setup do
      Rake::Task["retire:change_owning_application"].reenable
      ContentItemPublisher.any_instance.stubs(:reserve_path_for_publishing_app).returns(nil)
    end

    should "raise exception when base-path is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:change_owning_application"].invoke(nil, "a-publisher")
      end

      assert_equal "Missing base-path parameter", exception.message
    end

    should "raise exception when publishing_app not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:change_owning_application"].invoke("/base-path", nil)
      end

      assert_equal "Missing publishing_app parameter", exception.message
    end

    should "invoke reserve_path_for_publishing_app method on ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:reserve_path_for_publishing_app).with("/base-path", "a-publisher").once

      Rake::Task["retire:change_owning_application"].invoke("/base-path", "a-publisher")
    end
  end

  context "retire:publish_transaction rake task" do
    setup do
      Rake::Task["retire:publish_transaction"].reenable
      ContentItemPublisher.any_instance.stubs(:publish_transaction).returns(nil)
      ContentItemPublisher.any_instance.stubs(:reserve_path_for_publishing_app)
        .returns(nil)
    end

    should "raise exception when base-path is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_transaction"].invoke(
          nil,
          "publisher",
          "Sample transaction title",
          "Sample transaction content",
          "https://smaple.gov.uk/path/to/somewhere",
        )
      end

      assert_equal "Missing base path parameter", exception.message
    end

    should "raise exception when publishing_app is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_transaction"].invoke(
          "/base-path",
          nil,
          "Sample transaction title",
          "Sample transaction content",
          "https://smaple.gov.uk/path/to/somewhere",
        )
      end

      assert_equal "Missing publishing_app parameter", exception.message
    end

    should "raise exception when title is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_transaction"].invoke(
          "/base-path",
          "publisher",
          nil,
          "Sample transaction content",
          "https://smaple.gov.uk/path/to/somewhere",
        )
      end

      assert_equal "Missing title parameter", exception.message
    end

    should "raise exception when content is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_transaction"].invoke(
          "/base-path",
          "publisher",
          "Sample transaction title",
          nil,
          "https://smaple.gov.uk/path/to/somewhere",
        )
      end

      assert_equal "Missing content parameter", exception.message
    end

    should "raise exception when link is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_transaction"].invoke(
          "/base-path",
          "publisher",
          "Sample transaction title",
          "Sample transaction content",
          nil,
        )
      end

      assert_equal "Missing link parameter", exception.message
    end

    should "invoke publish_transaction method on ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance
      content_item_publisher_mock.expects(:publish_transaction).with(
        "/base-path",
        publishing_app: "publisher",
        title: "Sample transaction title",
        content: "Sample transaction content",
        link: "https://smaple.gov.uk/path/to/somewhere",
      ).once
      content_item_publisher_mock.expects(:reserve_path_for_publishing_app)
        .with("/base-path", "publisher").once

      Rake::Task["retire:publish_transaction"].invoke(
        "/base-path",
        "publisher",
        "Sample transaction title",
        "Sample transaction content",
        "https://smaple.gov.uk/path/to/somewhere",
      )
    end
  end

  context "retire:publish_answer rake task" do
    setup do
      ContentItemPublisher.any_instance.stubs(:reserve_path_for_publishing_app)
        .returns(nil)
      ContentItemPublisher.any_instance.stubs(:publish_answer).returns(nil)
      Rake::Task["retire:publish_answer"].reenable
    end

    should "raise exception when base path is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_answer"].invoke(
          nil,
          "publisher",
          "Sample answer title",
          "Sample answer content",
        )
      end

      assert_equal "Missing base path parameter", exception.message
    end

    should "raise exception when publishing application is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_answer"].invoke(
          "/base-path",
          nil,
          "Sample answer title",
          "Sample answer content",
        )
      end

      assert_equal "Missing publishing_app parameter", exception.message
    end

    should "raise exception when title is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_answer"].invoke(
          "/base-path",
          "publisher",
          nil,
          "Sample answer content",
        )
      end

      assert_equal "Missing title parameter", exception.message
    end

    should "raise exception when content is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:publish_answer"].invoke(
          "/base-path",
          "publisher",
          "Sample answer title",
          nil,
        )
      end

      assert_equal "Missing content parameter", exception.message
    end

    should "invoke publish_answer method on ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance
      content_item_publisher_mock.expects(:publish_answer).with(
        "/base-path",
        publishing_app: "publisher",
        title: "Sample answer title",
        content: "Sample answer content",
      ).once
      content_item_publisher_mock.expects(:reserve_path_for_publishing_app)
        .with("/base-path", "publisher").once

      Rake::Task["retire:publish_answer"].invoke(
        "/base-path",
        "publisher",
        "Sample answer title",
        "Sample answer content",
      )
    end
  end
end
