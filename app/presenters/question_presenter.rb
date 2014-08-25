class QuestionPresenter < NodePresenter

  def number(question_page_index=@state.path.size + 1, question_index=0)
    question_page_index + question_index
  end

  def response_label(value)
    value
  end

  def partial_template_name
    template_names = @node.class.ancestors.map do |klass|
      "#{klass.name.demodulize.underscore}_question"
    end
    template_names.first do |template_name|
      File.exist?(File.expand_path("../../views/smart_answers/_#{template_name}.html.erb", __FILE__))
    end
  end

  def multiple_responses?
    false
  end
end
