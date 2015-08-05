require 'test_helper'
require 'gds_api/test_helpers/imminence'

class SmartdownScenariosTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Imminence

  setup do
    imminence_has_areas_for_postcode("WC2B%206SE", [])
    imminence_has_areas_for_postcode("B1%201PW", [{ slug: "birmingham-city-council" }])
  end

  smartdown_flow_to_test = ENV['SMARTDOWN_FLOW_TO_TEST']
  run_all_tests = smartdown_flow_to_test.nil?

  flow_registry_options = {
    preload_flows: true,
    show_drafts: true,
    show_transitions: true,
  }
  SmartdownAdapter::Registry.reset_instance
  smartdown_flows = SmartdownAdapter::Registry.instance(flow_registry_options).flows
  smartdown_flows.each do |smartdown_flow|
    next unless run_all_tests || smartdown_flow.name == smartdown_flow_to_test

    smartdown_flow.scenario_sets.each do |scenario_set|
      scenario_set.scenarios.each_with_index do |scenario, scenario_index|
        description = scenario.description.empty? ? scenario_index + 1 : scenario.description
        test "scenario #{description} in set #{scenario_set.name} for flow #{smartdown_flow.name}" do
          scenario.question_groups.each_with_index do |question_group, question_index|
            answers = scenario.question_groups.take(question_index).flatten.map(&:answer)
            question_names = question_group.map(&:name)
            questions_are_asked(smartdown_flow, answers, question_names)
          end
          answers = scenario.question_groups.flatten.map(&:answer)
          outcome_is_reached(smartdown_flow, answers, scenario.outcome)
          markers_are_included(smartdown_flow, answers, scenario.markers)
          exact_markers_are_included(smartdown_flow, answers, scenario.exact_markers) if scenario.exact_markers.any?
        end
      end
    end
  end
  SmartdownAdapter::Registry.reset_instance

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
      assert_equal outcome,
                   state.current_node.name,
                   "In flow #{flow.name} with answers #{answers}, outcome #{state.current_node.name} was reached and not #{outcome}"
    end
  end

  def markers_are_included(flow, answers, expected_markers)
    state  = flow.state(true, answers)
    actual_markers = state.current_node.markers.map(&:marker_name)
    assert_empty (expected_markers - actual_markers),
      "In flow #{flow.name} with answers #{answers} markers #{expected_markers} were expected but #{actual_markers} was received"
  end

  def exact_markers_are_included(flow, answers, expected_markers)
    state  = flow.state(true, answers)
    actual_markers = state.current_node.markers.map(&:marker_name)
    assert_empty ((expected_markers - actual_markers) + (actual_markers - expected_markers)),
      "In flow #{flow.name} with answers #{answers} markers #{expected_markers} were expected but #{actual_markers} was received"
  end
end
