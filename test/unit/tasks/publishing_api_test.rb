require 'test_helper'

class PublishingApiRakeTest < ActiveSupport::TestCase
  context "publishing_api:unpublish rake task" do
    setup do
      Rake::Task["publishing_api:unpublish"].reenable
      ContentItemPublisher.any_instance.stubs(:unpublish).returns(nil)
    end

    should "raise exception when slug isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:unpublish"].invoke
      end

      assert_equal "Missing content-id parameter", exception.message
    end

    should "invoke the unpublished method from ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:unpublish).with("content-id").once

      Rake::Task["publishing_api:unpublish"].invoke("content-id")
    end
  end

  context "publishing_api:redirect_smart_answer rake task" do
    setup do
      Rake::Task["publishing_api:redirect_smart_answer"].reenable
      ContentItemPublisher.any_instance.stubs(:redirect_smart_answer).returns(nil)
    end

    should "raise exception when destination isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:redirect_smart_answer"].invoke("base-path", nil)
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "raise exception when path isn't defined" do
      exception = assert_raises RuntimeError do
        Rake::Task["publishing_api:redirect_smart_answer"].invoke(nil, "/destination-path")
      end

      assert_equal "Missing path parameter", exception.message
    end

    should "invoke the redirect_smart_answer method from ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:redirect_smart_answer).with("/base-path", "/destination-path").once

      Rake::Task["publishing_api:redirect_smart_answer"].invoke("/base-path", "/destination-path")
    end
  end
end
