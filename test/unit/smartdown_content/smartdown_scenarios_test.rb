require 'test_helper'
require 'gds_api/test_helpers/imminence'

class SmartdownScenariosTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Imminence

  setup do
    imminence_has_areas_for_postcode("WC2B%206SE", [])
    imminence_has_areas_for_postcode("B1%201PW", [{ slug: "birmingham-city-council" }])
  end

  SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS = {
    preload_flows: true,
    show_drafts: true,
    show_transitions: true,
  }
  smartdown_flows = SmartdownAdapter::Registry.instance.flows
  smartdown_flows.each do |smartdown_flow|
    smartdown_flow.scenario_sets.each do |scenario_set|
      scenario_set.scenarios.each_with_index do |scenario, scenario_index|
        test "scenario #{scenario.description || scenario_index+1} in set #{scenario_set.name} for flow #{smartdown_flow.name}" do
          scenario.question_groups.each_with_index do |question_group, question_index|
            answers = scenario.question_groups.take(question_index).flatten.map(&:answer)
            question_names = question_group.map(&:name)
            questions_are_asked(smartdown_flow, answers, question_names)
          end
          answers = scenario.question_groups.flatten.map(&:answer)
          outcome_is_reached(smartdown_flow, answers, scenario.outcome)
        end
      end
    end
  end

  def questions_are_asked(flow, answers, question_names)
    assert_nothing_raised("Exception was thrown when running flow #{flow.name} with answers #{answers}") do
      state  = flow.state(true, answers)
      assert (state.current_node.is_a? Smartdown::Api::QuestionPage),
             "Expected a question when running flow #{flow.name} with answers #{answers}"
      current_question_names = state.current_node.questions.map(&:name).map(&:to_s)
      question_names.each do |question_name|
        assert current_question_names.include?(question_name),
               "In flow #{flow.name} with answers #{answers}, questions #{current_question_names} were reached but not #{question_name}"
      end
    end
  end

  def outcome_is_reached(flow, answers, outcome)
    assert_nothing_raised("Exception was thrown when running flow #{flow.name} with answers #{answers}") do
      state  = flow.state(true, answers)
      assert (state.current_node.is_a? Smartdown::Api::Outcome),
             "Expected an outcome when running flow #{flow.name} with answers #{answers}"
      assert_equal state.current_node.name,
                   outcome,
                   "In flow #{flow.name} with answers #{answers}, outcome #{state.current_node.name} was reached and not #{outcome}"
    end
  end
end
