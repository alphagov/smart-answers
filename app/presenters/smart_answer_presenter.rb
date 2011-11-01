class SmartAnswerPresenter
  extend Forwardable
  include Rails.application.routes.url_helpers
  
  attr_reader :params, :flow
  
  def_delegator :flow, :display_name

  def body
  end
  
  def started?
    params.has_key?(:started)
  end
  
  def finished?
    current_node.is_a?(SmartAnswer::Outcome)
  end
  
  def initialize(params, flow)
    @params = params
    @flow = flow
  end
  
  def current_state
    @flow.process(responses)
  end
  
  def collapsed_questions
    @flow.path(responses).map { |name| @flow.node(name) }
  end
  
  def current_question_number
    responses.size + 1
  end
  
  def current_node
    @flow.node(current_state.current_node)
  end
  
  def change_collapsed_question_link(question_number)
    previous_responses = responses[0...question_number - 1]
    smart_answer_path(id: @params[:id], started: 'y', responses: previous_responses)
  end
  
  def responses
    case params[:responses]
    when NilClass
      []
    when Array
      params[:responses]
    else
      params[:responses].to_s.split('/')
    end
  end
  
  def response_for(question)
    responses[question.number - 1]
  end
end