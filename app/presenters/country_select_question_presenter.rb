class CountrySelectQuestionPresenter < QuestionPresenter
  def response_label(value)
    options.find { |option| option.slug == value }.name
  end

  def options
    @node.options
  end
end
