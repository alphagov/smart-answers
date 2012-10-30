class OptionalDateQuestionPresenter < QuestionPresenter
  def response_label(value)
    case value.to_s
    when /no/i then "No"
    else
      I18n.localize(Date.parse(value), format: :long)
    end
  end

  def start_date
    @node.range == false ? 1.year.ago : @node.range.begin
  end

  def end_date
    @node.range == false ? 3.years.from_now : @node.range.end
  end
end
