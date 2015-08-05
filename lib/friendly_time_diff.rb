module FriendlyTimeDiff
  def friendly_time_diff(from_time, to_time)
    FriendlyDateDiff.new(from_time.to_date, to_time.to_date).describe
  end

private
  class FriendlyDateDiff
    include ActionView::Helpers::TextHelper
    attr_reader :from_date, :to_date

    def initialize(from_date, to_date)
      @from_date = from_date
      @to_date = to_date
    end

    def describe
      date_parts.compact.join(", ")
    end

  private
    def date_parts
      [
        date_part('year', whole_years_away),
        date_part('month', whole_months_away),
        date_part('day', whole_days_away)
      ]
    end

    def date_part(label, amount)
      amount > 0 ? pluralize(amount, label) : nil
    end

    def whole_years_away
      month_difference / 12
    end

    def whole_months_away
      month_difference % 12
    end

    def month_difference
      m = 0
      begin
        m += 1
      end while (from_date >> m) <= to_date
      m - 1
    end

    def whole_days_away
      closest_month_anniversary_before_to_date = (from_date >> month_difference)
      (to_date - closest_month_anniversary_before_to_date).to_i
    end
  end
end
