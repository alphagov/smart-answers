class CountrySelectQuestionPresenter < QuestionPresenter
  def select_options
    @node.options.map do |option|
      {
        text: option.name,
        value: option.slug,
        selected: option.slug == response_for_current_question,
      }
    end
  end

  def response_label
    select_options.find { |option| option[:value] == response }[:text]
  end
end
