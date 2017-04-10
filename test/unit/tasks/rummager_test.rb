require "test_helper"

class RummagerRakeTest < ActiveSupport::TestCase
  context "rummager:remove_smart_answer_from_search rake task" do
    setup do
      Rake::Task["rummager:remove_smart_answer_from_search"].reenable
    end

    should "invoke the remove_smart_answer_from_search method from ContentItemPublisher" do
      ContentItemPublisher.any_instance.expects(:remove_smart_answer_from_search).with("/base-path").once

      Rake::Task["rummager:remove_smart_answer_from_search"].invoke("/base-path")
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["rummager:remove_smart_answer_from_search"].invoke
      end

      assert_equal "Missing base_path parameter", exception.message
    end
  end
end
