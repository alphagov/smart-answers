class CalculateYourHolidayEntitlementFlow < SmartAnswer::Flow
  def define
    content_id "deedf6f8-389b-4b34-a5b1-faa9ef909a70"
    name "calculate-your-holiday-entitlement"
    status :published

    # Q1
    radio :regular_or_irregular_hours? do
      option "irregular-hours-and-part-year"
      option "regular"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::HolidayEntitlement.new
        calculator.regular_or_irregular_hours = response
      end

      next_node do
        if calculator.regular_or_irregular_hours == "regular"
          question :basis_of_calculation?
        elsif calculator.regular_or_irregular_hours == "irregular-hours-and-part-year"
          question :when_does_your_leave_year_start?
        end
      end
    end

    radio :basis_of_calculation? do
      option "days-worked-per-week"
      option "hours-worked-per-week"
      option "annualised-hours"
      option "compressed-hours"
      option "shift-worker"

      on_response do |response|
        calculator.calculation_basis = response
      end

      next_node do
        case calculator.calculation_basis
        when "days-worked-per-week", "hours-worked-per-week", "compressed-hours", "annualised-hours"
          question :calculation_period?
        when "shift-worker"
          question :shift_worker_basis?
        end
      end
    end

    # Q2, Q35
    radio :calculation_period? do
      option "full-year"
      option "starting"
      option "leaving"
      option "starting-and-leaving"

      on_response do |response|
        calculator.holiday_period = response
      end

      next_node do
        case calculator.holiday_period
        when "starting", "starting-and-leaving"
          question :what_is_your_starting_date?
        when "leaving"
          question :what_is_your_leaving_date?
        when "full-year"
          case calculator.calculation_basis
          when "annualised-hours"
            outcome :annualised_done
          when "days-worked-per-week"
            question :how_many_days_per_week?
          else
            question :how_many_hours_per_week?
          end
        end
      end
    end

    # Q3 - Q7 - Q8
    value_question :how_many_days_per_week?, parse: Float do
      on_response do |response|
        calculator.working_days_per_week = response
      end

      validate :error_message do
        calculator.working_days_per_week.between?(1, 7)
      end

      next_node do
        outcome :days_per_week_done
      end
    end

    # Q4 - Q12 - Q20 - Q29 - Q36
    date_question :what_is_your_starting_date? do
      on_response do |response|
        calculator.start_date = response
      end

      next_node do
        if calculator.holiday_period == "starting-and-leaving"
          question :what_is_your_leaving_date?
        else
          question :when_does_your_leave_year_start?
        end
      end
    end

    # Q5 - Q13 - Q21 - Q29 - Q30 - Q37
    date_question :what_is_your_leaving_date? do
      on_response do |response|
        calculator.leaving_date = response
      end

      validate :error_end_date_before_start_date do
        calculator.holiday_period != "starting-and-leaving" || calculator.start_date.before?(calculator.leaving_date)
      end

      validate :error_end_date_outside_year_range do
        calculator.holiday_period != "starting-and-leaving" || SmartAnswer::YearRange.new(begins_on: calculator.start_date).include?(calculator.leaving_date)
      end

      next_node do
        if calculator.holiday_period == "starting-and-leaving"
          case calculator.calculation_basis
          when "days-worked-per-week"
            question :how_many_days_per_week?
          when "hours-worked-per-week", "compressed-hours"
            question :how_many_hours_per_week?
          when "shift-worker"
            question :shift_worker_hours_per_shift?
          when "annualised-hours"
            outcome :annualised_done
          end
        else
          question :when_does_your_leave_year_start?
        end
      end
    end

    # Q6 - Q14 - Q22 - Q31 - Q38
    date_question :when_does_your_leave_year_start? do
      on_response do |response|
        calculator.leave_year_start_date = response
      end

      validate :error_end_date_before_start_date do
        calculator.leaving_date.blank? || calculator.leave_year_start_date.before?(calculator.leaving_date)
      end

      validate :error_end_date_outside_leave_year_range do
        calculator.leaving_date.blank? || SmartAnswer::YearRange.new(begins_on: calculator.leave_year_start_date).include?(calculator.leaving_date)
      end

      validate :error_start_date_before_start_leave_year_date do
        calculator.start_date.nil? || calculator.leave_year_start_date.before?(calculator.start_date)
      end

      validate :error_start_date_outside_leave_year_range do
        calculator.start_date.nil? || SmartAnswer::YearRange.new(begins_on: calculator.leave_year_start_date).include?(calculator.start_date)
      end

      next_node do
        if calculator.regular_or_irregular_hours == "irregular-hours-and-part-year"

          if calculator.leave_year_start_date >= (Date.new(2024, 4, 1))
            question :hours_in_pay_period?
          else
            question :basis_of_calculation?
          end
        else
          case calculator.calculation_basis
          when "days-worked-per-week"
            question :how_many_days_per_week?
          when "hours-worked-per-week", "compressed-hours"
            question :how_many_hours_per_week?
          when "annualised-hours"
            outcome :annualised_done
          when "shift-worker"
            question :shift_worker_hours_per_shift?
          end
        end
      end
    end

    value_question :hours_in_pay_period?, parse: Float do
      on_response do |response|
        calculator.hours_in_pay_period = response
      end

      validate :error_no_hours_worked do
        calculator.hours_in_pay_period.positive?
      end

      next_node do
        outcome :irregular_hours_and_part_year_done
      end
    end

    # Q10 - Q15 - Q18
    value_question :how_many_hours_per_week?, parse: Float do
      on_response do |response|
        calculator.hours_per_week = response
      end

      validate :error_no_hours_worked do
        calculator.hours_per_week.positive?
      end

      validate :error_over_168_hours_worked do
        calculator.hours_per_week <= 168
      end

      next_node do
        question :how_many_days_per_week_for_hours?
      end
    end

    # Q11 - Q16 - Q19
    value_question :how_many_days_per_week_for_hours?, parse: Float do
      on_response do |response|
        calculator.working_days_per_week = response
      end

      validate :error_over_7_days_per_week do
        calculator.working_days_per_week.between?(1, 7)
      end

      validate :error_over_24_hours_per_day do
        calculator.hours_per_week.blank? || (calculator.hours_per_week / calculator.working_days_per_week) <= 24
      end

      next_node do
        if calculator.calculation_basis == "compressed-hours"
          outcome :compressed_hours_done
        else
          outcome :hours_per_week_done
        end
      end
    end

    radio :shift_worker_basis? do
      option "full-year"
      option "starting"
      option "leaving"
      option "starting-and-leaving"

      on_response do |response|
        calculator.holiday_period = response
      end

      next_node do
        case calculator.holiday_period
        when "full-year"
          question :shift_worker_hours_per_shift?
        when "starting", "starting-and-leaving"
          question :what_is_your_starting_date?
        when "leaving"
          question :what_is_your_leaving_date?
        end
      end
    end

    # Q26 - Q32
    value_question :shift_worker_hours_per_shift?, parse: Float do
      on_response do |response|
        calculator.hours_per_shift = response
      end

      validate :error_no_hours_worked do
        calculator.hours_per_shift.positive?
      end

      validate :error_over_24_hours_worked do
        calculator.hours_per_shift <= 24
      end

      next_node do
        question :shift_worker_shifts_per_shift_pattern?
      end
    end

    # Q27 - Q33
    value_question :shift_worker_shifts_per_shift_pattern?, parse: Integer do
      on_response do |response|
        calculator.shifts_per_shift_pattern = response
      end

      validate :error_message do
        calculator.shifts_per_shift_pattern.positive?
      end

      next_node do
        question :shift_worker_days_per_shift_pattern?
      end
    end

    # Q28 - Q34
    value_question :shift_worker_days_per_shift_pattern?, parse: Float do
      on_response do |response|
        calculator.days_per_shift_pattern = response
      end

      validate :error_message do
        calculator.days_per_shift_pattern >= calculator.shifts_per_shift_pattern
      end

      next_node do
        outcome :shift_worker_done
      end
    end

    # ======================================================================
    # Results
    # ======================================================================
    outcome :shift_worker_done
    outcome :days_per_week_done
    outcome :hours_per_week_done
    outcome :compressed_hours_done
    outcome :annualised_done
    outcome :irregular_hours_and_part_year_done
  end
end
