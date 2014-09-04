require 'test_helper'
require 'helpers/smartdown_adapter_helper'

module SmartdownAdapter
  class YearsUntilTrainingForgottenTest < ActiveSupport::TestCase
    include SmartdownAdapterHepler

    test "it should be 20 years after training date" do
      state = mock_smartdown_state({
        training_date: 5.years.ago.to_date.to_s
      })
      assert_equal 15, SmartdownAdapter::Plugins::YearsUntilTrainingForgotten.new.call(state)
    end
  end
end
