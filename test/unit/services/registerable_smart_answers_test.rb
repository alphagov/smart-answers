require 'test_helper'

class RegisterableSmartAnswersTest < ActiveSupport::TestCase
  test 'merging flow presenters and smartdown' do
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert_equal 2, flow_presenters.size
  end

  test 'decoration of smartanswers' do
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [stub('a flow', name: 'A SmartAnswer')])
    SmartdownAdapter::Registry.instance.stubs(flows: [])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert flow_presenters.first.is_a?(FlowRegistrationPresenter)
  end

  test 'decoration of smartdowns' do
    SmartAnswer::FlowRegistry.any_instance.stubs(flows: [])
    SmartdownAdapter::Registry.instance.stubs(flows: [stub('a flow', name: 'A SmartDown')])

    flow_presenters = RegisterableSmartAnswers.new.flow_presenters

    assert flow_presenters.first.is_a?(SmartdownAdapter::FlowRegistrationPresenter)
  end
end
