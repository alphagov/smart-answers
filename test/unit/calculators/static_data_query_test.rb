require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StaticDataQueryTest < ActiveSupport::TestCase
    context StaticDataQueryTest do
      setup do
        @query = SmartAnswer::Calculators::StaticDataQuery.new("apply_tier_4_visa_data")
      end
      context "initialize" do
        should "load the data" do
          assert_equal Hash, @query.data.class
          assert_equal @query.data.keys, ["post", "online"]
        end
        should "memoize the data" do
          YAML.expects(:load_file).at_most_once
          @query.class.load_data("apply_tier_4_visa_data")
          @query.class.load_data("apply_tier_4_visa_data")
        end
      end
    end
  end
end
