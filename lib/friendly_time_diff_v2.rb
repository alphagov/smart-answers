module FriendlyTimeDiffV2
  # Returns a more specific age between two given dates
  # in the readable format of years, months and days.

  def friendly_time_diff_v2(from_time, to_time)
    FriendlyDateDiffV2.new(from_time.to_date, to_time.to_date).describe
  end

private
  class FriendlyDateDiffV2
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
      days = (to_date - closest_month_anniversary_before_to_date).to_i
      days -= 1 if leap_year_birthday?
      days
    end

    def leap_year_birthday?
      Date.new(from_date.year).leap? && (from_date.month == 2 && from_date.day == 29)
    end
  end
end
