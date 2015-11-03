require 'test_helper'

class RegisterableSmartAnswersTest < ActiveSupport::TestCase
  test 'returns smart answers' do
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert_equal 1, flow_presenters.size
  end

  test 'decoration of smartanswers' do
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert flow_presenters.first.is_a?(FlowRegistrationPresenter)
  end
end
