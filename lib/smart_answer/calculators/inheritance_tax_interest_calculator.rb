require "ostruct"
require "bigdecimal"
require "bigdecimal/util"

module SmartAnswer::Calculators
  class InheritanceTaxInterestCalculator < OpenStruct
    INTEREST_RATES = [
      { start_date: "1988-10-06", end_date: "1989-07-05", value: 0.09 },
      { start_date: "1989-07-06", end_date: "1991-03-05", value: 0.11 },
      { start_date: "1991-03-06", end_date: "1991-05-05", value: 0.10 },
      { start_date: "1991-05-06", end_date: "1991-07-05", value: 0.09 },
      { start_date: "1991-07-06", end_date: "1992-11-05", value: 0.08 },
      { start_date: "1992-11-06", end_date: "1992-12-05", value: 0.06 },
      { start_date: "1992-12-06", end_date: "1994-01-05", value: 0.05 },
      { start_date: "1994-01-06", end_date: "1994-10-05", value: 0.04 },
      { start_date: "1994-10-06", end_date: "1999-03-05", value: 0.05 },
      { start_date: "1999-03-06", end_date: "2000-02-05", value: 0.04 },
      { start_date: "2000-02-06", end_date: "2001-05-05", value: 0.05 },
      { start_date: "2001-05-06", end_date: "2001-11-05", value: 0.04 },
      { start_date: "2001-11-06", end_date: "2003-08-05", value: 0.03 },
      { start_date: "2003-08-06", end_date: "2003-12-05", value: 0.02 },
      { start_date: "2003-12-06", end_date: "2004-09-05", value: 0.03 },
      { start_date: "2004-09-06", end_date: "2005-09-05", value: 0.04 },
      { start_date: "2005-09-06", end_date: "2006-09-05", value: 0.03 },
      { start_date: "2006-09-06", end_date: "2007-08-05", value: 0.04 },
      { start_date: "2007-08-06", end_date: "2008-01-05", value: 0.05 },
      { start_date: "2008-01-06", end_date: "2008-11-05", value: 0.04 },
      { start_date: "2008-11-06", end_date: "2009-01-05", value: 0.03 },
      { start_date: "2009-01-06", end_date: "2009-01-26", value: 0.02 },
      { start_date: "2009-01-27", end_date: "2009-03-23", value: 0.01 },
      { start_date: "2009-03-24", end_date: "2009-09-28", value: 0.0 },
      { start_date: "2009-09-29", end_date: "2016-08-22", value: 0.03 },
      { start_date: "2016-08-23", end_date: "2017-11-20", value: 0.0275 },
      { start_date: "2017-11-21", end_date: "2018-08-20", value: 0.03 },
      { start_date: "2018-08-21", end_date: "2020-03-29", value: 0.0325 },
      { start_date: "2020-03-30", end_date: "2020-04-06", value: 0.0275 },
      { start_date: "2020-04-07", end_date: "2022-01-06", value: 0.026 },
      { start_date: "2022-01-07", end_date: "2022-02-20", value: 0.0275 },
      { start_date: "2022-02-21", end_date: "2022-04-04", value: 0.03 },
      { start_date: "2022-04-05", end_date: "2022-05-23", value: 0.0325 },
      { start_date: "2022-05-24", end_date: "2022-07-04", value: 0.035 },
      { start_date: "2022-07-05", end_date: "2022-08-22", value: 0.0375 },
      { start_date: "2022-08-23", end_date: "2022-10-10", value: 0.0425 },
      { start_date: "2022-10-11", end_date: "2022-11-21", value: 0.0475 },
      { start_date: "2022-11-22", end_date: "2023-01-05", value: 0.055 },
      { start_date: "2023-01-06", end_date: "2023-02-20", value: 0.06 },
      { start_date: "2023-02-21", end_date: "2023-04-12", value: 0.065 },
      { start_date: "2023-04-13", end_date: "2023-05-30", value: 0.0675 },
      { start_date: "2023-05-31", end_date: "2023-07-10", value: 0.07 },
      { start_date: "2023-07-11", end_date: "2023-08-21", value: 0.075 },
      { start_date: "2023-08-22", end_date: "2024-08-19", value: 0.0775 },
      { start_date: "2024-08-20", end_date: "2024-11-25", value: 0.075 },
      { start_date: "2024-11-26", end_date: "2025-02-24", value: 0.0725 },
      { start_date: "2025-02-25", end_date: "2025-04-05", value: 0.07 },
      { start_date: "2025-04-06", end_date: "2025-05-27", value: 0.085 },
      { start_date: "2025-05-28", end_date: "2025-08-26", value: 0.0825 },
      { start_date: "2025-08-27", end_date: "2026-01-08", value: 0.08 },
      { start_date: "2026-01-09", end_date: "2100-01-01", value: 0.0775 },
    ].freeze

    def calculate_interest
      return SmartAnswer::Money.new(0) if start_date.blank? || end_date.blank? || inheritance_tax_owed.blank?

      s_date = start_date.is_a?(String) ? Date.parse(start_date) : start_date
      e_date = end_date.is_a?(String) ? Date.parse(end_date) : end_date
      tax = BigDecimal(inheritance_tax_owed.to_s)
      total_interest = BigDecimal("0")

      current_date = s_date
      while current_date <= e_date
        rate_entry = INTEREST_RATES.find do |r|
          current_date >= Date.parse(r[:start_date]) && current_date <= Date.parse(r[:end_date])
        end

        raise "No rate found for date #{current_date}" unless rate_entry

        period_end = [Date.parse(rate_entry[:end_date]), e_date].min
        days_in_period = (period_end - current_date).to_i + 1
        annual_rate = BigDecimal(rate_entry[:value].to_s.presence || "0")

        interest_for_period = (tax * annual_rate * days_in_period) / 366
        total_interest += interest_for_period

        current_date = period_end + 1
      end

      sprintf("%.2f", total_interest.round(2)).to_s
    end
  end
end
