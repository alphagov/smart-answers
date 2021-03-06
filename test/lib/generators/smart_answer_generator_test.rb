require "test_helper"
require "generators/smart_answer/smart_answer_generator"

class SmartAnswerGeneratorTest < Rails::Generators::TestCase
  tests SmartAnswerGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator %w[example_smart_answer]

      assert_file "app/flows/example_smart_answer_flow.rb" do |content|
        assert_match(/ExampleSmartAnswerFlow/, content)
        assert_match(/name "example-smart-answer"/, content)
        assert_match(/content_id/, content)
        assert_match(/status :draft/, content)
      end

      assert_file "app/flows/example_smart_answer_flow/start.erb" do |content|
        assert_match(/Example smart answer/, content)
      end

      assert_file "app/flows/example_smart_answer_flow/questions/question.erb"

      assert_file "app/flows/example_smart_answer_flow/outcomes/results.erb"

      assert_file "lib/smart_answer/calculators/example_smart_answer_calculator.rb" do |content|
        assert_match(/ExampleSmartAnswer/, content)
      end
    end
  end
end
