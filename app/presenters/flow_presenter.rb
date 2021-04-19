require "node_presenter"

class FlowPresenter
  include Rails.application.routes.url_helpers
  include ContentItemHelper

  attr_reader :params, :flow

  delegate :name,
           :content_id,
           :response_store,
           :questions,
           :use_escape_button?,
           :show_escape_link?,
           :hide_previous_answers_on_results_page?,
           to: :flow

  delegate :title, :meta_description, to: :start_node

  delegate :node_slug, to: :current_node

  def initialize(params, flow)
    @params = params
    @flow = flow
    @node_presenters = {}
  end

  def started?
    params.key?(:started)
  end

  def finished?
    current_node.outcome?
  end

  def publish?
    @flow.status == :published
  end

  def current_state
    @current_state ||= if response_store
                         requested_node = params[:node_name] unless params[:next]
                         @flow.resolve_state(params[:responses], requested_node)
                       else
                         @flow.process(all_responses)
                       end
  end

  def collapsed_questions
    @flow.path(all_responses).map do |name|
      presenter_for(@flow.node(name))
    end
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
    @node_presenters[node.name] ||= presenter_class.new(node, self, current_state, {}, params)
  end

  def response_for_current_question
    if response_store
      all_responses[current_state.current_node.to_s]
    else
      question_number = current_state.path.size
      all_responses[question_number - 1]
    end
  end

  def current_question_number
    current_state.path.size + 1
  end

  def current_node
    presenter_for(@flow.node(current_state.current_node))
  end

  def start_node
    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    @start_node ||= StartNodePresenter.new(node)
  end

  def change_collapsed_question_link(question_number, question)
    if response_store
      flow_path(params[:id], node_slug: question.node_slug)
    else
      smart_answer_path(
        id: @params[:id],
        started: "y",
        responses: accepted_responses[0...question_number - 1],
        previous_response: accepted_responses[question_number - 1],
      )
    end
  end

  def normalize_responses_param
    case params[:responses]
    when NilClass
      []
    when Array, Hash, ActionController::Parameters
      params[:responses]
    else
      params[:responses].to_s.split("/")
    end
  end

  def accepted_responses
    @current_state.responses
  end

  def all_responses
    normalize_responses_param.dup.tap do |responses|
      responses << params[:response] if params[:next]
    end
  end

  def flows_content
    extract_flow_content(@flow, start_node)
  end

  def start_page_link
    if response_store
      start_flow_path(name)
    else
      smart_answer_path(name, started: "y")
    end
  end
end
