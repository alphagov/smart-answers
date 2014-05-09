module FriendlyTimeDiff
  include ActionView::Helpers::TextHelper

  def friendly_time_diff(from_time, to_time)
    from = from_time.to_date
    to = to_time.to_date
    [
      whole_years_away(from, to),
      whole_months_away(from, to),
      whole_days_away(from, to)
    ].compact.join(", ")
  end

private
  def whole_years_away(from_date, to_date)
    y = 0
    while (from_date >> 12) <= to_date
      from_date >>= 12
      y+=1
    end
    if y > 0
      pluralize(y, 'year')
    end
  end

  def whole_months_away(from_date, to_date)
    while (from_date >> 12) <= to_date
      from_date >>= 12
    end
    m = 0
    while (from_date >> 1) <= to_date
      from_date >>= 1
      m += 1
    end
    if m > 0
      pluralize(m, 'month')
    end
  end

  def whole_days_away(from_date, to_date)
    while (from_date >> 12) <= to_date
      from_date >>= 12
    end
    while (from_date >> 1) <= to_date
      from_date >>= 1
    end
    days = (to_date - from_date).to_i
    if days > 0
      pluralize(days, 'day')
    end
  end
end
