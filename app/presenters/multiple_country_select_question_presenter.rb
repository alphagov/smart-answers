class MultipleCountrySelectQuestionPresenter < QuestionPresenter
  def select_count
    @node.select_count
  end

  def select_options(counter)
    @node.options.map do |option|
      {
        text: option.name,
        value: option.slug,
        selected: current_response.nil? ? false : option.slug == current_response[counter.to_s],
      }
    end
  end
end
