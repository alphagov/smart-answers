class DateQuestionPresenter < QuestionPresenter
  delegate :default_day,
           :default_month,
           :default_year,
           to: :@node

  def response_label(value)
    if only_display_day_and_month?(value)
      value.strftime("%e %B")
    else
      value.strftime("%e %B %Y")
    end
  end

  def parsed_response
    return {} if current_response.blank?
    return current_response if current_response.is_a?(Hash)

    date = @node.parse_input(current_response)
    {
      day: date.day,
      month: date.month,
      year: date.year,
    }
  rescue SmartAnswer::InvalidResponse
    {}
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
