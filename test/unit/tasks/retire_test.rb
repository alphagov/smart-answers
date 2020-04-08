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
end
