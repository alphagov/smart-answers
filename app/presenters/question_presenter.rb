class QuestionPresenter < NodePresenter
  def title
    translate!('title') || @node.name.to_s.humanize
  end

  def response_label(value)
    value
  end

  def partial_template_name
    "#{@node.class.name.demodulize.underscore}_question"
  end

  def multiple_responses?
    false
  end
end
