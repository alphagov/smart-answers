require_relative "../test_helper"

class FlowPresenterTest < ActiveSupport::TestCase
  setup do
    @flow = SmartAnswer::Flow.new do
      name 'flow-name'
      value_question :first_question_key
    end
    @request = ActionDispatch::TestRequest.new
    @flow_presenter = FlowPresenter.new(@request, @flow)
  end

  test '#presenter_for returns presenter for Date question' do
    question = @flow.date_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of DateQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for CountrySelect question' do
    question = @flow.country_select(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of CountrySelectQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for MultipleChoice question' do
    question = @flow.multiple_choice(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of MultipleChoiceQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for Checkbox question' do
    question = @flow.checkbox_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of CheckboxQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for Value question' do
    question = @flow.value_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of ValueQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for Money question' do
    question = @flow.money_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of MoneyQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for Salary question' do
    question = @flow.salary_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of SalaryQuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for other question types' do
    question = @flow.send(:add_question, SmartAnswer::Question::Base, :question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of QuestionPresenter, node_presenter
  end

  test '#presenter_for returns presenter for outcome' do
    outcome = @flow.outcome(:outcome_key).last
    node_presenter = @flow_presenter.presenter_for(outcome)
    assert_instance_of OutcomePresenter, node_presenter
  end

  test '#presenter_for returns presenter for other node types' do
    node = @flow.send(:add_question, SmartAnswer::Node, :node_key).last
    node_presenter = @flow_presenter.presenter_for(node)
    assert_instance_of NodePresenter, node_presenter
  end

  test '#presenter_for always returns same presenter for a given question' do
    question = @flow.multiple_choice(:question_key).last
    node_presenter_1 = @flow_presenter.presenter_for(question)
    node_presenter_2 = @flow_presenter.presenter_for(question)
    assert_same node_presenter_1, node_presenter_2
  end

  test '#start_node returns presenter for landing page node' do
    start_node = @flow_presenter.start_node
    assert_instance_of StartNodePresenter, start_node
  end
end
