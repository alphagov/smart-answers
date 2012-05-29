require 'node_presenter'
class SmartAnswerPresenter
  extend Forwardable
  include Rails.application.routes.url_helpers

  attr_reader :request, :params, :flow

  def_delegators :@flow, :section_slug, :subsection_slug, :need_id

  def initialize(request, flow)
    @request = request
    @params = request.params
    @flow = flow
  end

  def i18n_prefix
    "flow.#{@flow.name}"
  end

  def lookup_translation(key)
    I18n.translate!("#{i18n_prefix}.#{key}")
  rescue I18n::MissingTranslationData
    nil
  end

  def markdown_for(key)
    markdown = lookup_translation(key)
    markdown && Govspeak::Document.new(markdown).to_html.html_safe
  end

  def title
    lookup_translation(:title) || @flow.name.to_s.humanize
  end

  def section_name
    lookup_translation(:section_name) || @flow.section_slug.to_s.humanize
  end

  def subtitle
    lookup_translation(:subtitle)
  end

  def body
    markdown_for('body')
  end

  def devolved_body
    markdown_for('devolved_body')
  end

  def has_subtitle?
    !! subtitle
  end

  def has_body?
    !! body
  end

  def has_devolved_body?
    !! devolved_body
  end

  def has_meta_description?
    !! lookup_translation('meta.description')
  end

  def meta_description
    lookup_translation('meta.description')
  end

  def started?
    params.has_key?(:started)
  end

  def finished?
    current_node.outcome?
  end

  def current_state
    @current_state ||= @flow.process(all_responses)
  end

  def error
    if current_state.error.present?
      current_node.error_message || I18n.translate('flow.defaults.error_message')
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
    when SmartAnswer::Question::MultipleChoice
      MultipleChoiceQuestionPresenter
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
    else NodePresenter
    end
    presenter_class.new(i18n_prefix, node, current_state)
  end

  def current_question_number
    current_state.path.size + 1
  end

  def current_node
    presenter_for(@flow.node(current_state.current_node))
  end

  def change_collapsed_question_link(question_number)
    smart_answer_path(
      id: @params[:id],
      started: 'y',
      responses: accepted_responses[0...question_number - 1],
      previous_response: accepted_responses[question_number - 1]
    )
  end

  def normalize_responses_param
    case params[:responses]
    when NilClass
      []
    when Array
      params[:responses]
    else
      params[:responses].to_s.split('/')
    end
  end

  def accepted_responses
    @current_state.responses
  end

  def all_responses
    normalize_responses_param.dup.tap do |responses|
      if params[:next]
        responses << params[:response]
      end
    end
  end
end
