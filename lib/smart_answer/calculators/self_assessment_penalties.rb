require "ostruct"

module SmartAnswer::Calculators
  class SelfAssessmentPenalties < OpenStruct
    ONLINE_FILING_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 January").freeze
    ONLINE_FILING_DEADLINE_YEAR_FEB = SmartAnswer::YearRange.resetting_on("28 February").freeze
    OFFLINE_FILING_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 October").freeze
    PAYMENT_DEADLINE_YEAR = SmartAnswer::YearRange.resetting_on("31 January").freeze
    PENALTY_YEAR = SmartAnswer::YearRange.resetting_on("1 February").freeze

    DEADLINES = {
      online_filing_deadline: {
        "2014-15": ONLINE_FILING_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2015-16": ONLINE_FILING_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2016-17": ONLINE_FILING_DEADLINE_YEAR.starting_in(2018).begins_on,
        "2017-18": ONLINE_FILING_DEADLINE_YEAR.starting_in(2019).begins_on,
        "2018-19": ONLINE_FILING_DEADLINE_YEAR.starting_in(2020).begins_on,
        "2019-20": ONLINE_FILING_DEADLINE_YEAR.starting_in(2021).begins_on,
        "2019-20-covid-easement": ONLINE_FILING_DEADLINE_YEAR_FEB.starting_in(2021).begins_on,
        "2020-21": ONLINE_FILING_DEADLINE_YEAR.starting_in(2022).begins_on,
      },
      paper_filing_deadline: {
        "2014-15": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2015).begins_on,
        "2015-16": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2016-17": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2017-18": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2018).begins_on,
        "2018-19": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2019).begins_on,
        "2019-20": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2020).begins_on,
        "2020-21": OFFLINE_FILING_DEADLINE_YEAR.starting_in(2021).begins_on,
      },
      payment_deadline: {
        "2014-15": PAYMENT_DEADLINE_YEAR.starting_in(2016).begins_on,
        "2015-16": PAYMENT_DEADLINE_YEAR.starting_in(2017).begins_on,
        "2016-17": PAYMENT_DEADLINE_YEAR.starting_in(2018).begins_on,
        "2017-18": PAYMENT_DEADLINE_YEAR.starting_in(2019).begins_on,
        "2018-19": PAYMENT_DEADLINE_YEAR.starting_in(2020).begins_on,
        "2019-20": PAYMENT_DEADLINE_YEAR.starting_in(2021).begins_on,
        "2020-21": PAYMENT_DEADLINE_YEAR.starting_in(2022).begins_on,
      },
    }.freeze

    def tax_year_range
      case tax_year
      when "2014-15"
        SmartAnswer::YearRange.tax_year.starting_in(2014)
      when "2015-16"
        SmartAnswer::YearRange.tax_year.starting_in(2015)
      when "2016-17"
        SmartAnswer::YearRange.tax_year.starting_in(2016)
      when "2017-18"
        SmartAnswer::YearRange.tax_year.starting_in(2017)
      when "2018-19"
        SmartAnswer::YearRange.tax_year.starting_in(2018)
      when "2019-20"
        SmartAnswer::YearRange.tax_year.starting_in(2019)
      when "2020-21"
        SmartAnswer::YearRange.tax_year.starting_in(2020)
      end
    end

    def start_of_next_tax_year
      tax_year_range.next.begins_on
    end

    def one_year_after_start_date_for_penalties
      case tax_year
      when "2014-15"
        PENALTY_YEAR.starting_in(2017).begins_on
      when "2015-16"
        PENALTY_YEAR.starting_in(2018).begins_on
      when "2016-17"
        PENALTY_YEAR.starting_in(2019).begins_on
      when "2017-18"
        PENALTY_YEAR.starting_in(2020).begins_on
      when "2018-19"
        PENALTY_YEAR.starting_in(2021).begins_on
      when "2019-20"
        PENALTY_YEAR.starting_in(2022).begins_on
      when "2020-21"
        PENALTY_YEAR.starting_in(2023).begins_on
      end
    end

    def valid_filing_date?
      filing_date >= start_of_next_tax_year
    end

    def valid_payment_date?
      return true if tax_year == "2019-20"

      filing_date <= payment_date
    end

    def paid_on_time?
      (filing_date <= filing_deadline) && (payment_date <= payment_deadline)
    end

    def late_filing_penalty
      # Less than 6 months
      if overdue_filing_days <= 0
        result = 0
      elsif submission_method == "online"
        if overdue_filing_days <= 89
          result = 100
        elsif overdue_filing_days <= 181
          result = (overdue_filing_days - 89) * 10 + 100
          # this fine can't be more than 1000£
          if result > 1000
            result = 1000
          end
        end
      elsif overdue_filing_days <= 92
        result = 100
      elsif overdue_filing_days <= 181
        result = (overdue_filing_days - 92) * 10 + 100
        # this fine can't be more than 1000£
        if result > 1000
          result = 1000
        end
      end

      # More than 6 months, same for paper and online return
      if (overdue_filing_days > 181) && (overdue_filing_days <= 365)
        # if 5% of tax due is higher than 300£ then charge 5% of tax due otherwise charge 300£
        result = if estimated_bill.value > 6002
                   1000 + (estimated_bill.value * 0.05)
                 else
                   1000 + 300
                 end
        # if more than 1 year
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

      days_with_penalty_interest = payment_deadline..interest_accrual_start_date_for_year
      interest_charges_per_day = days_with_penalty_interest.map do |date|
        calculate_interest_for_date(date)
      end

      SmartAnswer::Money.new(interest_charges_per_day.sum.round(2))
    end

    def interest_accrual_start_date_for_year
      tax_year == "2019-20" ? payment_date - 1.day : payment_date - 2.days
    end

    def first_late_payment_days
      tax_year == "2019-20" ? 60 : 30
    end

    def total_owed
      SmartAnswer::Money.new((estimated_bill.value + interest.to_f + late_payment_penalty.to_f).floor)
    end

    def total_owed_plus_filing_penalty
      SmartAnswer::Money.new(total_owed.value + late_filing_penalty.value)
    end

    def late_payment_penalty
      if overdue_payment_days <= first_late_payment_days
        0
      elsif overdue_payment_days <= 183
        SmartAnswer::Money.new(late_payment_penalty_part.round(2))
      elsif overdue_payment_days <= 367
        SmartAnswer::Money.new((late_payment_penalty_part * 2).round(2))
      else
        SmartAnswer::Money.new((late_payment_penalty_part * 3).round(2))
      end
    end

    def overdue_filing_days
      (filing_date - filing_deadline).to_i
    end

    def overdue_payment_days
      (payment_date - payment_deadline).to_i
    end

  private

    def late_payment_penalty_part
      0.05 * estimated_bill.value
    end

    def filing_deadline
      deadline_period = filed_during_covid_deadline_easement? ? "#{tax_year}-covid-easement" : tax_year
      DEADLINES[:"#{submission_method}_filing_deadline"][deadline_period.to_sym]
    end

    def filed_during_covid_deadline_easement?
      tax_year == "2019-20" && filing_date < Date.parse("2021-03-01")
    end

    def payment_deadline
      DEADLINES[:payment_deadline][tax_year.to_sym]
    end

    def calculate_interest_for_date(date)
      estimated_bill.value * daily_rate(date)
    end

    def daily_rate(date)
      # Rate decreased to 2.6% on 7 April 2020
      rate_change_date = Date.new(2020, 4, 7)
      if date < rate_change_date
        0.0325 / 365.0
      else
        0.026 / 365.0
      end
    end
  end
end
