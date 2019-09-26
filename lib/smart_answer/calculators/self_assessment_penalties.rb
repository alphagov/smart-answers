require "ostruct"

module SmartAnswer::Calculators
  class SelfAssessmentPenalties < OpenStruct
    ONLINE_FILING_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 January").freeze
    OFFLINE_FILING_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 October").freeze
    PAYMENT_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 January").freeze
    PENALTY_YEAR = SmartAnswer::YearRange.resetting_on("1 February").freeze

    DEADLINES = {
      online_filing_deadline: {
        "2012-13": ONLINE_FILING_DEADLINE_YEAR.starting_in(2014).begins_on,
        "2013-14": ONLINE_FILING_DEADLINE_YEAR.starting_in(2015).begins_on,
        "2014-15": ONLINE_FILING_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2015-16": ONLINE_FILING_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2016-17": ONLINE_FILING_DEADLINE_YEAR.starting_in(2018).begins_on,
        "2017-18": ONLINE_FILING_DEADLINE_YEAR.starting_in(2019).begins_on,
      },
      offline_filing_deadline: {
        "2012-13": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2013).begins_on,
        "2013-14": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2014).begins_on,
        "2014-15": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2015).begins_on,
        "2015-16": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2016-17": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2017-18": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2018).begins_on,
      },
      payment_deadline: {
        "2012-13": PAYMENT_DEADLINE_YEAR.starting_in(2014).begins_on,
        "2013-14": PAYMENT_DEADLINE_YEAR.starting_in(2015).begins_on,
        "2014-15": PAYMENT_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2015-16": PAYMENT_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2016-17": PAYMENT_DEADLINE_YEAR.starting_in(2018).begins_on,
        "2017-18": PAYMENT_DEADLINE_YEAR.starting_in(2019).begins_on,
      },
    }.freeze

    def tax_year_range
      case tax_year
      when "2012-13"
        SmartAnswer::YearRange.tax_year.starting_in(2012)
      when "2013-14"
        SmartAnswer::YearRange.tax_year.starting_in(2013)
      when "2014-15"
        SmartAnswer::YearRange.tax_year.starting_in(2014)
      when "2015-16"
        SmartAnswer::YearRange.tax_year.starting_in(2015)
      when "2016-17"
        SmartAnswer::YearRange.tax_year.starting_in(2016)
      when "2017-18"
        SmartAnswer::YearRange.tax_year.starting_in(2017)
      end
    end

    def start_of_next_tax_year
      tax_year_range.next.begins_on
    end

    def one_year_after_start_date_for_penalties
      case tax_year
      when "2012-13"
        PENALTY_YEAR.starting_in(2015).begins_on
      when "2013-14"
        PENALTY_YEAR.starting_in(2016).begins_on
      when "2014-15"
        PENALTY_YEAR.starting_in(2017).begins_on
      when "2015-16"
        PENALTY_YEAR.starting_in(2018).begins_on
      when "2016-17"
        PENALTY_YEAR.starting_in(2019).begins_on
      when "2017-18"
        PENALTY_YEAR.starting_in(2020).begins_on
      end
    end

    def valid_filing_date?
      filing_date >= start_of_next_tax_year
    end

    def valid_payment_date?
      filing_date <= payment_date
    end

    def paid_on_time?
      (filing_date <= filing_deadline) && (payment_date <= payment_deadline)
    end

    def late_filing_penalty
      #Less than 6 months
      if overdue_filing_days <= 0
        result = 0
      elsif submission_method == "online"
        if overdue_filing_days <= 89
          result = 100
        elsif overdue_filing_days <= 181
          result = (overdue_filing_days - 89) * 10 + 100
          #this fine can't be more than 1000£
          if result > 1000
            result = 1000
          end
        end
      elsif overdue_filing_days <= 92
        result = 100
      elsif overdue_filing_days <= 181
        result = (overdue_filing_days - 92) * 10 + 100
        #this fine can't be more than 1000£
        if result > 1000
          result = 1000
        end
      end

      #More than 6 months, same for paper and online return
      if (overdue_filing_days > 181) && (overdue_filing_days <= 365)
        #if 5% of tax due is higher than 300£ then charge 5% of tax due otherwise charge 300£
        result = if estimated_bill.value > 6002
                   1000 + (estimated_bill.value * 0.05)
                 else
                   1000 + 300
                 end
        #if more than 1 year
      elsif overdue_filing_days > 365
        # if 5% of tax due is higher than 300£ then charge 5% of tax due otherwise charge 300£ + all other fines
        result = if estimated_bill.value > 6002
                   1000 + (estimated_bill.value * 0.05) + (estimated_bill.value * 0.05)
                 else
                   1000 + 600
                 end
      end
      SmartAnswer::Money.new(result)
    end

    def interest
      return 0 if overdue_payment_days <= 0

      days_with_penalty_interest = payment_deadline..(payment_date - 2)
      interest_charges_per_day = days_with_penalty_interest.map do |date|
        calculate_interest_for_date(date)
      end

      SmartAnswer::Money.new(interest_charges_per_day.sum.round(2))
    end

    def total_owed
      SmartAnswer::Money.new((estimated_bill.value + interest.to_f + late_payment_penalty.to_f).floor)
    end

    def total_owed_plus_filing_penalty
      SmartAnswer::Money.new(total_owed.value + late_filing_penalty.value)
    end

    def late_payment_penalty
      if overdue_payment_days <= 30
        0
      elsif overdue_payment_days <= 181
        SmartAnswer::Money.new(late_payment_penalty_part.round(2))
      elsif overdue_payment_days <= 365
        SmartAnswer::Money.new((late_payment_penalty_part * 2).round(2))
      else
        SmartAnswer::Money.new((late_payment_penalty_part * 3).round(2))
      end
    end

  private

    def overdue_filing_days
      (filing_date - filing_deadline).to_i
    end

    def overdue_payment_days
      (payment_date - payment_deadline).to_i
    end

    def late_payment_penalty_part
      0.05 * estimated_bill.value
    end

    def filing_deadline
      submission_method == "online" ? DEADLINES[:online_filing_deadline][tax_year.to_sym] : DEADLINES[:offline_filing_deadline][tax_year.to_sym]
    end

    def payment_deadline
      DEADLINES[:payment_deadline][tax_year.to_sym]
    end

    def calculate_interest_for_date(date)
      estimated_bill.value * daily_rate(date)
    end

    def daily_rate(date)
      # Rate drops from 3% to 2.75% on 23 August 2016
      rate_change_date = Date.new(2016, 8, 23)
      if date < rate_change_date
        0.03 / 365.0
      else
        0.0275 / 365.0
      end
    end
  end
end
