class DateQuestionPresenter < QuestionPresenter
  include CurrentQuestionHelper
  delegate %i[default_day default_month default_year] => :@node

  def response_label(value)
    if only_display_day_and_month?(value)
      value.strftime("%e %B")
    else
      value.strftime("%e %B %Y")
    end
  end

  def error_id
    "error_id" if error
  end

  def days_options
    days = Array(1..31).map { |number|
      format_date(number, :day)
    }
    days.unshift(text: "", value: "")
  end

  def months_options
    months = Array(1..12).map { |number|
      format_date(number, :month)
    }
    months.unshift(text: "", value: "")
  end

  def years_options
    smallest = [start_date.year, end_date.year].min
    biggest = [start_date.year, end_date.year].max

    years = Array(smallest..biggest).map { |number|
      format_date(number, :year)
    }
    years.unshift(text: "", value: "")
  end

private

  def only_display_day_and_month?(value)
    value.year.zero?
  end

  def start_date
    @node.range == false ? 1.year.ago : @node.range.begin
  end

  def end_date
    @node.range == false ? 3.years.from_now : @node.range.end
  end

  def format_date(number, type)
    {
      text: type.eql?(:month) ? Date::MONTHNAMES[number] : number,
      value: number,
      selected: default_for_date(prefill_value_for(self, type)) == number,
    }
  end
end
