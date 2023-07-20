class QuestionPresenter < NodePresenter
  delegate :current_response, to: :@flow_presenter

  attr_reader :params

  def initialize(node, flow_presenter, state = nil, options = {})
    super(node, flow_presenter, state)
    @renderer = options[:renderer]
    helpers = options[:helpers] || []
    @renderer ||= SmartAnswer::ErbRenderer.new(
      template_directory: @node.template_directory.join("questions"),
      template_name: @node.template_name,
      locals: @state.to_hash,
      helpers: [SmartAnswer::RateDatesHelper, SmartAnswer::FormattingHelper] + helpers,
    )
  end

  def error_id(template)
    types = %w[radio_question checkbox_question date_question]

    fragment = types.any? { |type| type == template } ? "response\-0" : "response"
    "##{fragment}"
  end

  def title
    @renderer.content_for(:title)
  end

  def error
    if @state.error.present?
      error_message_for(@state.error) || error_message_for("error_message") || default_error_message
    end
  end

  def error_message_for(key)
    message = @renderer.content_for(key.to_sym)
    message.presence
  end

  def hint
    @renderer.content_for(:hint).presence
  end

  def caption
    return nil if @renderer.hide_caption
    return @renderer.content_for(:caption) if @renderer.content_for(:caption).present?

    @flow_presenter.title
  end

  def label
    @renderer.content_for(:label)
  end

  def suffix_label
    content = @renderer.content_for(:suffix_label)
    content.presence
  end

  def prefix_label
    content = @renderer.content_for(:prefix_label)
    content.presence
  end

  def body
    @renderer.content_for(:body).presence
  end

  def post_body
    @renderer.content_for(:post_body)
  end

  def options
    []
  end

  def response_label(value)
    value
  end

  def change_link_track_label(value)
    if redacted?
      "#{title} / [FILTERED]"
    else
      "#{title} / #{response_label(value)}"
    end
  end

  def partial_template_name
    "#{@node.class.name.demodulize.underscore}_question"
  end

  def multiple_responses?
    false
  end

  def default_error_message
    "Please answer this question"
  end

  def view_template_path
    "smart_answers/question"
  end
end
