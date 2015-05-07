class DateQuestionPresenter < QuestionPresenter
  def response_label(value)
    I18n.localize(value.to_date, format: :long)
  end

  def start_date
    @node.range == false ? 1.year.ago : @node.range.begin
  end

  def end_date
    @node.range == false ? 3.years.from_now : @node.range.end
  end
end
