require_relative "../test_helper"

class FlowPresenterTest < ActiveSupport::TestCase
  def flow_registry
    SmartAnswer::FlowRegistry.instance
  end

  setup do
    @flow = SmartAnswer::Flow.new do
      name "flow-name"
      value_question :first_question_key do
        next_node { question :second_question_key }
      end
      value_question :second_question_key do
        next_node { question :third_question_key }
      end
      value_question :third_question_key do
        next_node { outcome :outcome_key }
      end
    end
    params = {}
    @flow_presenter = FlowPresenter.new(params, @flow)
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

  test "#presenter_for returns presenter for MultipleChoice question" do
    question = @flow.radio(:question_key).last
    node_presenter = @flow_presenter.presenter_for(question)
    assert_instance_of MultipleChoiceQuestionPresenter, node_presenter
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

  context "#response_for_current_question" do
    should "get the response for the current page for url-based smart-answers when previous_response" do
      params = { id: @flow.name, responses: "question-1-answer", previous_response: "question-2-answer" }
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal("question-2-answer", flow_presenter.response_for_current_question)
    end

    should "leave response for the current page blank for url-based smart-answers when no previous_response" do
      params = { id: @flow.name, responses: "question-1-answer/question-2-answer" }
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_nil(flow_presenter.response_for_current_question)
    end

    should "get the response for the current page for session-based smart-answers" do
      @flow.response_store(:session)
      params = { id: @flow.name, node_name: "first_question_key", responses: { "first_question_key" => "question-1-answer", "second_question_key" => "question-2-answer" } }
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal("question-1-answer", flow_presenter.response_for_current_question)
    end
  end

  context "#change_collapsed_question_link" do
    should "with smart answer" do
      flow = flow_registry.find("calculate-your-holiday-entitlement")
      params = { responses: "days-worked-per-week/starting", id: "calculate-your-holiday-entitlement" }
      flow_presenter = FlowPresenter.new(params, flow)
      questions = flow_presenter.collapsed_questions
      assert_equal(
        "/calculate-your-holiday-entitlement/y?previous_response=days-worked-per-week",
        flow_presenter.change_collapsed_question_link(1, questions.first),
      )
      assert_equal(
        "/calculate-your-holiday-entitlement/y/days-worked-per-week?previous_response=starting",
        flow_presenter.change_collapsed_question_link(2, questions.first),
      )
      assert_equal(
        "/calculate-your-holiday-entitlement/y/days-worked-per-week?previous_response=starting",
        flow_presenter.change_collapsed_question_link(2, questions.last),
      )
    end

    should "with session answer" do
      @flow.response_store(:session)
      params = { id: @flow.name, node_name: "third_question_key", responses: { "first_question_key" => "question-1-answer", "second_question_key" => "question-2-answer" } }
      flow_presenter = FlowPresenter.new(params, @flow)
      question = OpenStruct.new(node_slug: "foo")
      assert_equal(
        flow_presenter.flow_path(@flow.name, question.node_slug),
        flow_presenter.change_collapsed_question_link(1, question),
      )
    end
  end

  context "#normalize_responses_param" do
    should "return empty array when no responses in params" do
      params = {}
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal [], flow_presenter.normalize_responses_param
    end

    should "return array when responses in an array" do
      array = (1..5).to_a
      params = { responses: array }
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal array, flow_presenter.normalize_responses_param
    end

    should "return responses from state when no responses are parameters" do
      params = ActionController::Parameters.new(responses: "y")
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal %w[y], flow_presenter.normalize_responses_param
    end

    should "return array of parts when responses in params are path" do
      array = (1..5).to_a
      params = { responses: array.join("/") }
      flow_presenter = FlowPresenter.new(params, @flow)
      assert_equal array.map(&:to_s), flow_presenter.normalize_responses_param
    end
  end

  context "publish?" do
    should "return true for a published flow" do
      @flow.status(:published)
      flow_presenter = FlowPresenter.new({}, @flow)
      assert flow_presenter.publish?
    end

    should "return false true for a draft flow" do
      @flow.status(:draft)
      flow_presenter = FlowPresenter.new({}, @flow)
      assert_not flow_presenter.publish?
    end
  end

  context "#start_page_link" do
    should "return path to first page in smart flow" do
      assert_equal "/flow-name/y", @flow_presenter.start_page_link
    end

    should "return path to first page in session flow using sessions" do
      @flow.response_store(:session)
      flow_presenter = FlowPresenter.new({}, @flow)
      assert_equal "/flow-name/s", flow_presenter.start_page_link
    end
  end
end
