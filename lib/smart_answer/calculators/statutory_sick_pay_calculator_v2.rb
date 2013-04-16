module SmartAnswer::Calculators
  class StatutorySickPayCalculatorV2

    def self.months_between(start_date, end_date)
      end_month = end_date.month
      current_month = start_date.next_month
      count = 0
      count += 1 if start_date.day < 17
      count += 1 if end_date.day > 15
      while current_month.month != end_month
        count +=1
        current_month = current_month.next_month
      end
      count
    end

    def self.lel
      109
    end

  end
end
