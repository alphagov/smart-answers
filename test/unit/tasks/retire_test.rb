require 'test_helper'

class RetireSmartAnswerRakeTest < ActiveSupport::TestCase
  context "retire:smart_answer rake task" do
    setup do
      Rake::Task["retire:smart_answer"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke("content-id", nil)
      end

      assert_equal "Missing base_path parameter", exception.message
    end

    should "raise exception when destination isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke(
          "content-id",
          "/base-path",
          nil
        )
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "invoke the unpublish, redirect_smart_answer and remove_smart_answer_from_search methods from ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance

      content_item_publisher_mock.stubs(:unpublish).returns(nil)
      content_item_publisher_mock.stubs(:redirect_smart_answer).returns(nil)
      content_item_publisher_mock.stubs(:remove_smart_answer_from_search)
        .returns(nil)

      content_item_publisher_mock.expects(:unpublish).with("content-id").once
      content_item_publisher_mock.expects(:redirect_smart_answer)
        .with("/base-path", "/new-destination").once
      content_item_publisher_mock.expects(:remove_smart_answer_from_search)
        .with("/base-path").once

      Rake::Task["retire:smart_answer"].invoke(
        "content-id",
        "/base-path",
        "/new-destination"
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

  context "retire:redirect rake task" do
    setup do
      Rake::Task["retire:redirect_smart_answer"].reenable
      ContentItemPublisher.any_instance.stubs(:redirect_smart_answer).returns(nil)
    end

    should "raise exception when path isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:redirect_smart_answer"].invoke(nil, "/destination-path")
      end

      assert_equal "Missing path parameter", exception.message
    end

    should "raise exception when destination isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:redirect_smart_answer"].invoke("base-path", nil)
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "invoke the redirect_smart_answer method on ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:redirect_smart_answer).with("/base-path", "/destination-path").once

      Rake::Task["retire:redirect_smart_answer"].invoke("/base-path", "/destination-path")
    end
  end

  context "retire:remove_smart_answer_from_search rake task" do
    setup do
      Rake::Task["retire:remove_smart_answer_from_search"].reenable
      ContentItemPublisher.any_instance.stubs(:remove_smart_answer_from_search).returns(nil)
    end

    should "raise exception when base-path is not defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:remove_smart_answer_from_search"].invoke
      end

      assert_equal "Missing base-path parameter", exception.message
    end

    should "invoke the remove_smart_answer_from_search method on ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:remove_smart_answer_from_search).with("/base-path").once

      Rake::Task["retire:remove_smart_answer_from_search"].invoke("/base-path")
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
          "https://smaple.gov.uk/path/to/somewhere"
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
          "https://smaple.gov.uk/path/to/somewhere"
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
          "https://smaple.gov.uk/path/to/somewhere"
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
          "https://smaple.gov.uk/path/to/somewhere"
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
          nil
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
        link: "https://smaple.gov.uk/path/to/somewhere"
      ).once
      content_item_publisher_mock.expects(:reserve_path_for_publishing_app)
        .with("/base-path", "publisher").once

      Rake::Task["retire:publish_transaction"].invoke(
        "/base-path",
        "publisher",
        "Sample transaction title",
        "Sample transaction content",
        "https://smaple.gov.uk/path/to/somewhere"
      )
    end
  end
end
