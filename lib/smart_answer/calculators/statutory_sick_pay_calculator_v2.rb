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

    def self.average_weekly_earnings(args)
      pay, pay_pattern, monthly_pattern_payments = args.values_at(:pay, :pay_pattern, :monthly_pattern_payments)
      case pay_pattern
      when "weekly", "fortnightly", "every_4_weeks"
        pay / 8.0
      when "monthly"
        pay / monthly_pattern_payments * 12.0 / 52
      when "irregularly"
        relevant_period_to, relevant_period_from = args.values_at(:relevant_period_to, :relevant_period_from)
        pay / (relevant_period_to - relevant_period_from).to_i * 7
      end
    end

  end
end
