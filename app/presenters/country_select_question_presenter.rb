class CountrySelectQuestionPresenter < QuestionPresenter
  def select_options
    @node.options.map do |option|
      {
        text: option.name,
        value: option.slug,
        selected: option.slug == response,
      }
    end
  end

  def response_label
    select_options.find { |option| option[:value] == response }[:text]
  end
end
