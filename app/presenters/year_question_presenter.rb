class YearQuestionPresenter < QuestionPresenter
  def response_label(value)
    value
  end

  def parsed_response
    return {} if current_response.blank?

    year = @node.parse_input(current_response)
    {
      year:,
    }
  rescue SmartAnswer::InvalidResponse
    {}
  end
end
