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

  def selected_day
    return if response_for_current_question.blank?

    response_for_current_question[:day]
  end

  def selected_month
    return if response_for_current_question.blank?

    response_for_current_question[:month]
  end

  def selected_year
    return if response_for_current_question.blank?

    response_for_current_question[:year]
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
