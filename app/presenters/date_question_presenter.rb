class DateQuestionPresenter < QuestionPresenter
  delegate [:default_day, :default_month, :default_year] => :@node

  def response_label(value)
    if only_display_day_and_month?(value)
      value.strftime("%e %B")
    else
      value.strftime("%e %B %Y")
    end
  end

  def start_date
    @node.range == false ? 1.year.ago : @node.range.begin
  end

  def end_date
    @node.range == false ? 3.years.from_now : @node.range.end
  end

  private

  def only_display_day_and_month?(value)
    value.year.zero?
  end
end
