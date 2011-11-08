require 'node_presenter'
class SmartAnswerPresenter
  extend Forwardable
  include Rails.application.routes.url_helpers
  
  attr_reader :params, :flow
  
  def i18n_prefix
    "flow.#{@flow.name}"
  end
  
  def title
    I18n.translate!("#{i18n_prefix}.title")
  rescue I18n::MissingTranslationData
    @flow.name.to_s.humanize
  end
  
  def subtitle
    I18n.translate!("#{i18n_prefix}.subtitle")
  rescue I18n::MissingTranslationData
    nil
  end
  
  def has_subtitle?
    !! subtitle
  end
  
  def body
    translated = I18n.translate!("#{i18n_prefix}.body")
    Govspeak::Document.new(translated).to_html.html_safe
  end
  
  def has_body?
    true if I18n.translate!("#{i18n_prefix}.body")
  rescue I18n::MissingTranslationData
    false
  end
  
  def started?
    params.has_key?(:started)
  end
  
  def finished?
    current_node.is_outcome?
  end
  
  def initialize(params, flow)
    @params = params
    @flow = flow
  end
  
  def current_state
    @current_state ||= @flow.process(responses)
  end
  
  def collapsed_questions
    @flow.path(responses).map do |name| 
      presenter_for(@flow.node(name))
    end
  end
  
  def presenter_for(node)
    presenter_class = case node
    when SmartAnswer::Question::Date
      DateQuestionPresenter
    when SmartAnswer::Question::MultipleChoice
      MultipleChoiceQuestionPresenter
    when SmartAnswer::Question::Value
      ValueQuestionPresenter
    when SmartAnswer::Question::Money
      MoneyQuestionPresenter
    when SmartAnswer::Question::Base
      QuestionPresenter
    else NodePresenter
    end
    presenter_class.new(i18n_prefix, node, current_state)
  end
  
  def current_question_number
    responses.size + 1
  end
  
  def current_node
    presenter_for(@flow.node(current_state.current_node))
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
end