require "ostruct"

module SmartAnswer::Calculators
  class SelfAssessmentPenalties < OpenStruct
    DEADLINES = {
      online_filing_deadline: {
        "2011-12": Date.new(2013, 1, 31),
        "2012-13": Date.new(2014, 1, 31),
        "2013-14": Date.new(2015, 1, 31),
      },
      offline_filing_deadline: {
        "2011-12": Date.new(2012, 10, 31),
        "2012-13": Date.new(2013, 10, 31),
        "2013-14": Date.new(2014, 10, 31),
      },
      payment_deadline: {
        "2011-12": Date.new(2013, 1, 31),
        "2012-13": Date.new(2014, 1, 31),
        "2013-14": Date.new(2015, 1, 31),
      },
    }

    def start_of_next_tax_year
      if tax_year == '2011-12'
        Date.new(2012, 4, 6)
      elsif tax_year == '2012-13'
        Date.new(2013, 4, 6)
      else
        Date.new(2014, 4, 6)
      end
    end

    def one_year_after_start_date_for_penalties
      if tax_year == '2011-12'
        Date.new(2014, 2, 01)
      elsif tax_year == '2012-13'
        Date.new(2015, 2, 01)
      else
        Date.new(2016, 2, 01)
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
      else
        if overdue_filing_days <= 92
          result = 100
        elsif overdue_filing_days <= 181
          result = (overdue_filing_days - 92) * 10 + 100
          #this fine can't be more than 1000£
          if result > 1000
            result = 1000
          end
        end
      end

      #More than 6 months, same for paper and online return
      if (overdue_filing_days > 181) && (overdue_filing_days <= 365)
        #if 5% of tax due is higher than 300£ then charge 5% of tax due otherwise charge 300£
        if estimated_bill.value > 6002
          result = 1000 + (estimated_bill.value * 0.05)
        else
          result = 1000 + 300
        end
        #if more than 1 year
      elsif overdue_filing_days > 365
        # if 5% of tax due is higher than 300£ then charge 5% of tax due otherwise charge 300£ + all other fines
        if estimated_bill.value > 6002
          result = 1000 + (estimated_bill.value * 0.05) + (estimated_bill.value * 0.05)
        else
          result = 1000 + 600
        end
      end
      SmartAnswer::Money.new(result)
    end

    def interest
      if overdue_payment_days <= 0
        0
      else
        SmartAnswer::Money.new(calculate_interest(estimated_bill.value, overdue_payment_days).round(2))
      end
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

    #interest is 3% per annum
    def calculate_interest(amount, number_of_days)
      (amount * (0.03 / 365) * (number_of_days - 1)).round(10)
    end
  end
end
