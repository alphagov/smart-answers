# Alpha API presenter to support the chatbot firebreak (https://trello.com/b/OZ9IlfwI/govbot-firebreak)
class ApiPresenter
  include ActionView::Helpers::SanitizeHelper

  attr_reader :flow_presenter
  delegate :current_node, to: :flow_presenter

  def initialize(flow_presenter)
    @flow_presenter = flow_presenter
  end

  def as_json
    {
      _warning: "This is an unsupported API that will probably be removed!",
    }.merge(payload)
  end

private

  def payload
    if current_node.is_a?(OutcomePresenter)
      if current_node.title.present?
        outcome_text = current_node.title
      else
        strip_tags(current_node.body(html: true)).strip.lines.first
      end

      {
        state: "finished",
        title: current_node.title,
        body: current_node.body,
        outcome: outcome_text,
      }
    else
      {
        state: "asking",
        question_type: current_node.class.name.underscore.gsub("_presenter", ""),
        title: current_node.title,
        body: strip_tags(current_node.body),
        hint: current_node.hint,
        error: current_node.error,
        questions: current_node.options.map(&:to_h),
      }
    end
  end
end
