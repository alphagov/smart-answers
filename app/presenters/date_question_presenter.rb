class DateQuestionPresenter < QuestionPresenter
  include CurrentQuestionHelper

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
    prefill_value_for(self, :day)
  end

  def selected_month
    prefill_value_for(self, :month)
  end

  def selected_year
    prefill_value_for(self, :year)
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
