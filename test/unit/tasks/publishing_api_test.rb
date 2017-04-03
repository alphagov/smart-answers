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
end
