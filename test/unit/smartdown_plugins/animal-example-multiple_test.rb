require 'test_helper'
require 'smartdown_plugins/animal-example-multiple'

module SmartdownPlugins
  class AnimalExampleMultipeTest < ActiveSupport::TestCase
    test ".years_until_training_forgotten should return years until 20 years after training date" do
      assert_equal 15, SmartdownPlugins::AnimalExampleMultiple.years_until_training_forgotten(5.years.ago.to_date.to_s)
    end
  end
end
