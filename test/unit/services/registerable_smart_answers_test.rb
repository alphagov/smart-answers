require 'test_helper'

class RegisterableSmartAnswersTest < ActiveSupport::TestCase
  def test_merging_flow_presenters_and_smartdown
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert_equal 2, flow_presenters.size
  end

  def test_decoration_of_smartanswers
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert flow_presenters.first.is_a?(FlowRegistrationPresenter)
  end

  def test_decoration_of_smartdowns
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert flow_presenters.first.is_a?(SmartdownAdapter::FlowRegistrationPresenter)
  end
end
