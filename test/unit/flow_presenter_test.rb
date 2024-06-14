require_relative "../test_helper"

class FlowPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def flow_registry
    SmartAnswer::FlowRegistry.instance
  end

  setup do
    @flow = SmartAnswer::Flow.build do
      name "flow-name"
      value_question :first_question_key do
        next_node { question :second_question_key }
      end
      value_question :second_question_key do
        next_node { outcome :outcome_key }
      end
    end
    state = SmartAnswer::State.new(:first_question_key)
    @flow_presenter = FlowPresenter.new(@flow, state)
  end

  test "#presenter_for returns presenter for Year question" do
    question = @flow.year_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of YearQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Date question" do
    question = @flow.date_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of DateQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for CountrySelect question" do
    question = @flow.country_select(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of CountrySelectQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Radio question" do
    question = @flow.radio(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of RadioQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Checkbox question" do
    question = @flow.checkbox_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of CheckboxQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Value question" do
    question = @flow.value_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of ValueQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Money question" do
    question = @flow.money_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of MoneyQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for Salary question" do
    question = @flow.salary_question(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of SalaryQuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for other question types" do
    question = SmartAnswer::Question::Base.new(@flow, :question_key)
    @flow.send(:add_node, question)
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of QuestionPresenter, node_presenter
  end

  test "#presenter_for returns presenter for outcome" do
    outcome = @flow.outcome(:outcome_key).last
    node_presenter = @flow_presenter.presenter_for(outcome)
    assert_instance_of OutcomePresenter, node_presenter
  end

  test "#presenter_for returns presenter for other node types" do
    node = SmartAnswer::Node.new(@flow, :node_key)
    @flow.send(:add_node, node)
    node_presenter = @flow_presenter.presenter_for(node)
    assert_instance_of NodePresenter, node_presenter
  end

  test "#presenter_for always returns same presenter for a given question" do
    question = @flow.radio(:question_key).last
    node_presenter1 = @flow_presenter.presenter_for(question)
    node_presenter2 = @flow_presenter.presenter_for(question)
    assert_same node_presenter1, node_presenter2
  end

  test "#start_node returns presenter for landing page node" do
    start_node = @flow_presenter.start_node
    assert_instance_of StartNodePresenter, start_node
  end

  test "#start_node always returns same presenter for landing page node" do
    start_node1 = @flow_presenter.start_node
    start_node2 = @flow_presenter.start_node
    assert_same start_node1, start_node2
  end

  test "#name returns Flow name" do
    assert_equal @flow_presenter.name, @flow.name
  end

  test "#change_answer_link returns a previous question link for a response store flow" do
    @flow.response_store(:query_parameters)
    state = SmartAnswer::State.new(:second_question_key)
    flow_presenter = FlowPresenter.new(@flow, state)
    question = OpenStruct.new(node_slug: "foo")
    assert_equal(
      "/#{@flow.name}/foo?first_question_key=answer",
      flow_presenter.change_answer_link(question, { first_question_key: "answer" }),
    )
  end

  test "#change_answer_link returns a previous question link for a non response store flow" do
    state = SmartAnswer::StateResolver.new(@flow).state_from_params({ responses: "question-1-answer/question-2-answer" })
    flow_presenter = FlowPresenter.new(@flow, state)
    questions = flow_presenter.answered_questions
    assert_equal(
      "/#{@flow.name}/y/question-1-answer?previous_response=question-2-answer",
      flow_presenter.change_answer_link(questions.last, {}),
    )
  end

  test "#start_page_link returns the start page link for a response store flow" do
    @flow.response_store(:query_parameters)
    flow_presenter = FlowPresenter.new(@flow, nil)
    assert_equal "/flow-name/start?key=value", flow_presenter.start_page_link({ "key" => "value" })
  end

  test "#start_page_link returns the start page link for a non response store flow" do
    assert_equal "/flow-name/y", @flow_presenter.start_page_link({ "key" => "value" })
  end

  test "#start_page_link returns the new flow when we're in marriage-abroad" do
    @flow = SmartAnswer::Flow.build do
      name "marriage-abroad"
    end
    @flow_presenter = FlowPresenter.new(@flow, nil)
    assert_equal(
      "https://www.prove-eligibility-foreign-government.service.gov.uk/before-you-start",
      @flow_presenter.start_page_link({ "key" => "value" }),
    )
  end
end
