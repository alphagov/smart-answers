require 'test_helper'
require 'smartdown_plugins/animal-example-multiple/render_time'

module SmartdownPlugins
  class AnimalExampleMultipeTest < ActiveSupport::TestCase
    test ".years_until_training_forgotten should return years until 20 years after training date" do
      assert_equal 15, SmartdownPlugins::AnimalExampleMultiple.years_until_training_forgotten(
        Smartdown::Model::Answer::Date.new(5.years.ago.to_date.to_s)
      )
    end
  end
end
