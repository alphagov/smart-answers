class DateQuestionPresenter < QuestionPresenter
  delegate :default_day,
           :default_month,
           :default_year,
           to: :@node

  def response_label
    if only_display_day_and_month?(response)
      value.strftime("%e %B")
    else
      value.strftime("%e %B %Y")
    end
  end

  def selected_day
    return unless response_for_current_question.is_a? Hash

    response_for_current_question[:day]
  end

  def selected_month
    return unless response_for_current_question.is_a? Hash

    response_for_current_question[:month]
  end

  def selected_year
    return unless response_for_current_question.is_a? Hash

    response_for_current_question[:year]
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
