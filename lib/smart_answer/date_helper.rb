module SmartAnswer
  module DateHelper
    def next_saturday(date)
      (1..7).each do |inc|
        return date + inc if (date + inc).saturday?
      end
    end

    def formatted_date(date)
      date.strftime("%d %B %Y")
    end

    def self.current_day
      if ENV["RATES_QUERY_DATE"]
        Date.parse(ENV["RATES_QUERY_DATE"])
      else
        Date.today
      end
    end
  end
end
