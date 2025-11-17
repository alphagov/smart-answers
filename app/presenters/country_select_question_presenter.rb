class CountrySelectQuestionPresenter < QuestionPresenter
  def select_options
    @node.options.map do |option|
      if option.slug == "usa"
        {
          text: "United States of America",
          value: option.slug,
          selected: option.slug == current_response,
        }
      else
        {
          text: option.name,
          value: option.slug,
          selected: option.slug == current_response,
        }
      end
    end
  end

  def response_label(value)
    select_options.find { |option| option[:value] == value }[:text]
  end
end
