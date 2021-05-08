require "node_presenter"

class FlowPresenter
  include Rails.application.routes.url_helpers

  attr_reader :params, :flow

  delegate :name,
           :response_store,
           :questions,
           :use_hide_this_page?,
           :hide_previous_answers_on_results_page?,
           to: :flow

  delegate :title, :meta_description, to: :start_node

  delegate :node_slug, to: :current_node

  def initialize(flow, state)
    @flow = flow
    @state = state
    @node_presenters = {}
  end

  def current_node
    @current_node ||= @flow.visited_nodes(@state).last
  end

  def presenter_for(node)
    presenter_class = case node
                      when SmartAnswer::Question::Date
                        DateQuestionPresenter
                      when SmartAnswer::Question::CountrySelect
                        CountrySelectQuestionPresenter
                      when SmartAnswer::Question::Radio
                        MultipleChoiceQuestionPresenter
                      when SmartAnswer::Question::Checkbox
                        CheckboxQuestionPresenter
                      when SmartAnswer::Question::Value
                        ValueQuestionPresenter
                      when SmartAnswer::Question::Money
                        MoneyQuestionPresenter
                      when SmartAnswer::Question::Salary
                        SalaryQuestionPresenter
                      when SmartAnswer::Question::Base
                        QuestionPresenter
                      when SmartAnswer::Outcome
                        OutcomePresenter
                      else
                        NodePresenter
                      end
    @node_presenters[node.name] ||= presenter_class.new(node, self, @state, {}, params)
  end

  def current_node_presenter
    presenter_for(current_node)
  end

  def start_node
    @start_node ||= StartNodePresenter.new(@flow.start_node)
  end

  def accepted_responses
    @state.responses
  end

  def finished?
    current_node.outcome?
  end

  # def answered_questions
  #   @state.responses.keys.map do |node_name|
  #     presenter_for(@flow.find_node(node_name))
  #   end
  # end

  def previous_questions
    nodes = @flow.visited_nodes(@state)
    nodes.pop

    nodes.map do |node|
      presenter_for(node)
    end
  end

  def change_answer_link(question)
    if response_store
      flow_path(flow.name, node_slug: question.node_slug, params: {})
    else
      question_index = previous_questions.index { |q| q.node_name == question.node_name }
      responses = previous_questions[..question_index - 1].map(&:response)

      smart_answer_path(
        id: flow.name,
        started: "y",
        responses: responses,
        previous_response: question.response,
      )
    end
  end

  def start_page_link
    if response_store
      start_flow_path(name)
    else
      smart_answer_path(name, started: "y")
    end
  end
end
