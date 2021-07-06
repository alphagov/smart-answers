require "node_presenter"

class FlowPresenter
  include Rails.application.routes.url_helpers

  attr_reader :flow, :state

  delegate :name,
           :response_store,
           :questions,
           :use_hide_this_page?,
           :hide_previous_answers_on_results_page?,
           to: :flow

  delegate :title, :meta_description, to: :start_node
  delegate :node_slug, to: :current_node
  delegate :accepted_responses, :forwarding_responses, :current_response, to: :state

  def initialize(flow, state)
    @flow = flow
    @state = state
    @node_presenters = {}
  end

  def finished?
    current_node.outcome?
  end

  def answered_questions
    accepted_responses.keys.map { |name| presenter_for(@flow.node(name)) }
  end

  def presenter_for(node)
    @node_presenters[node.name] ||= node.presenter(flow_presenter: self, state: state)
  end

  def current_node
    presenter_for(@flow.node(state.current_node_name))
  end

  def start_node
    @start_node ||= @flow.start_node.presenter(flow_presenter: self)
  end

  def change_answer_link(question)
    if response_store
      flow_path(@flow.name, node_slug: question.node_slug, params: forwarding_responses)
    else
      question_number = accepted_responses.keys.index(question.node_name) || 1

      smart_answer_path(
        id: @flow.name,
        started: "y",
        responses: accepted_responses.values[0...question_number],
        previous_response: accepted_responses[question.node_name],
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
