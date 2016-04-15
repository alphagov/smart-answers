require_relative '../integration_test_helper'

class FlowVisualisationTest < ActionDispatch::IntegrationTest
  SmartAnswer::FlowRegistry.instance.flows.each do |flow|
    should "be able to visualise #{flow.name}" do
      presenter = GraphPresenter.new(flow)
      assertion_message = "The #{flow.name} Smart Answers isn't visualisable"

      assert presenter.visualisable?, assertion_message
    end
  end
end
