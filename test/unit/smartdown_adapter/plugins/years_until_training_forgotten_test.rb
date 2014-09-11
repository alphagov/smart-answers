require 'test_helper'

module SmartdownAdapter
  class YearsUntilTrainingForgottenTest < ActiveSupport::TestCase
    test "it should be 20 years after training date" do
      assert_equal 15, SmartdownAdapter::Plugins::YearsUntilTrainingForgotten.new.call(5.years.ago.to_date.to_s)
    end
  end
end
