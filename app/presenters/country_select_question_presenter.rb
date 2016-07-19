class CountrySelectQuestionPresenter < QuestionPresenter
  def response_label(value)
    options.find { |option| option.value == value }.label
  end

  def options
    @node.options.map do |option|
      OpenStruct.new(label: option.name, value: option.slug)
    end
  end
end
