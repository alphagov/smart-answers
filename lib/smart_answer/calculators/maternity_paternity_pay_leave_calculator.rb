module SmartAnswer::Calculators
  class MaternityPaternityPayLeaveCalculator
    include ActiveModel::Model

    attr_accessor :two_carers,
                  :where_does_the_mother_partner_live,
                  :due_date,
                  :mother_employment_status,
                  :partner_employment_status,
                  :mother_started_working_before_continuity_start_date,
                  :mother_still_working_on_continuity_end_date,
                  :mother_earned_more_than_lower_earnings_limit,
                  :mother_worked_at_least_26_weeks,
                  :mother_earned_at_least_390,
                  :partner_started_working_before_continuity_start_date,
                  :partner_still_working_on_continuity_end_date,
                  :partner_earned_more_than_lower_earnings_limit

    APRIL_2024_PATERNITY_LEAVE_RULES_CHANGE_DATE = "2024-04-07".freeze

    def first_day_in_year(year)
      date = Date.new(year, 4, 1)
      offset = (7 - date.wday) % 7

      date + offset
    end

    def last_day_in_year(year)
      first_day_in_year(year + 1) - 1
    end

    def formatted_first_day_in_year(year)
      first_day_in_year(year).strftime("%e %B %Y")
    end

    def formatted_last_day_in_year(year)
      last_day_in_year(year).strftime("%e %B %Y")
    end

    def two_carers?
      two_carers == "yes"
    end

    def continuity_start_date
      saturday_before(due_date - 39.weeks)
    end

    def continuity_end_date
      sunday_before(due_date - 15.weeks)
    end

    def lower_earnings_amount
      tax_year_start = SmartAnswer::YearRange.tax_year
        .including(lower_earnings_end_date)
        .begins_on

      case tax_year_start.year
      when 2013
        SmartAnswer::Money.new(109)
      when 2014
        SmartAnswer::Money.new(111)
      when 2015
        SmartAnswer::Money.new(112)
      when 2016
        SmartAnswer::Money.new(112)
      when 2017
        SmartAnswer::Money.new(113)
      when 2018
        SmartAnswer::Money.new(116)
      when 2019
        SmartAnswer::Money.new(118)
      when 2020, 2021
        SmartAnswer::Money.new(120)
      when 2022, 2023, 2024
        SmartAnswer::Money.new(123)
      when 2025
        SmartAnswer::Money.new(125)
      when 2026
        SmartAnswer::Money.new(129)
      else
        SmartAnswer::Money.new(129)
      end
    end

    WORKING_STATUSES = %w[employee worker].freeze
    NON_EMPLOYMENT_STATUSES = %w[unemployed self-employed].freeze

    def mother_is_employee?
      calculator.mother_employment_status == "employee"
    end

    def mother_is_worker?
      calculator.mother_employment_status == "worker"
    end

    def mother_is_self_employed?
      calculator.mother_employment_status == "self-employed"
    end
    def mother_employee_or_worker?
      WORKING_STATUSES.include?(mother_employment_status)
    end

    def mother_self_employed_or_unemployed?
      NON_EMPLOYMENT_STATUSES.include?(mother_employment_status)
    end

    def mother_employee_or_self_employed?
      %w[employee self-employed].include?(calculator.mother_employment_status)
    end

    def mother_worker_or_self_employed?
      %w[worker self-employed].include?(calculator.mother_employment_status)
    end

    def partner_employee_or_worker?
      WORKING_STATUSES.include?(partner_employment_status)
    end

    def partner_self_employed_or_unemployed?
      NON_EMPLOYMENT_STATUSES.include?(partner_employment_status)
    end

    def partner_is_self_employed?
      calculator.partner_employment_status == "self-employed"
    end

    def partner_is_unemployed?
      calculator.partner_employment_status == "unemployed"
    end

    def lower_earnings_start_date
      saturday_before(due_date - 22.weeks)
    end

    def lower_earnings_end_date
      saturday_before(due_date - 14.weeks)
    end

    def earnings_employment_start_date
      sunday_before(due_date - 66.weeks)
    end

    def earnings_employment_end_date
      saturday_before(due_date)
    end

    def mother_continuity?
      mother_started_working_before_continuity_start_date == "yes" && mother_still_working_on_continuity_end_date == "yes"
    end

    def partner_continuity?
      partner_started_working_before_continuity_start_date == "yes" && partner_still_working_on_continuity_end_date == "yes"
    end

    def mother_earnings_employment?
      mother_worked_at_least_26_weeks == "yes" && (mother_employment_status == "self-employed" || mother_earned_at_least_390 == "yes")
    end

    def paid_leave_is_in_year?(year)
      (paid_leave_period & SmartAnswer::YearRange.new(begins_on: first_day_in_year(year))).number_of_days.positive?
    end

    def paid_leave_period
      SmartAnswer::DateRange.new(
        begins_on: due_date,
        ends_on: due_date + 39.weeks,
      )
    end

    def start_of_maternity_allowance
      sunday_before(due_date - 11.weeks)
    end

    def earliest_start_mat_leave
      start_of_maternity_allowance
    end

    def maternity_leave_notice_date
      saturday_before(due_date - 14.weeks)
    end

    def give_paternity_leave_notice_by_date
      if due_date_on_or_after(APRIL_2024_PATERNITY_LEAVE_RULES_CHANGE_DATE) && !mother_partner_living_in_northern_ireland
        due_date - 28.days
      else
        maternity_leave_notice_date
      end
    end

    def take_paternity_leave_by_date
      if due_date_on_or_after(APRIL_2024_PATERNITY_LEAVE_RULES_CHANGE_DATE) && !mother_partner_living_in_northern_ireland
        due_date + 364.days
      else
        due_date + 56.days
      end
    end

    def due_date_notice_to_partner_employer
      due_date - 105.days
    end

  private

    def mother_partner_living_in_northern_ireland
      where_does_the_mother_partner_live == "northern_ireland"
    end

    def due_date_on_or_after(date)
      due_date >= Date.parse(date)
    end

    def saturday_before(date)
      (date - date.wday) - 1.day
    end

    def sunday_before(date)
      date - date.wday
    end
  end
end
