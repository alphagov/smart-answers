require 'test_helper'

class RegisterableSmartAnswersTest < ActiveSupport::TestCase
  def test_merging_smart_answers_and_smartdown
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    registerables = RegisterableSmartAnswers.new.unique_registerables

    assert_equal 2, registerables.size
  end

  def test_decoration_of_smartanswers
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [])

    registerables = RegisterableSmartAnswers.new.unique_registerables

    assert registerables.first.is_a?(FlowRegistrationPresenter)
  end

  def test_decoration_of_smartdowns
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    registerables = RegisterableSmartAnswers.new.unique_registerables

    assert registerables.first.is_a?(SmartdownAdapter::FlowRegistrationPresenter)
  end
end
