module SmartAnswer
  class CalculateAgriculturalHolidayEntitlementFlow < Flow
    def define
      start_page_content_id "8834bc7c-7ac7-4d45-8a57-1d5a5dcd70a0"
      name 'calculate-agricultural-holiday-entitlement'
      status :published
      satisfies_need "100143"

      multiple_choice :work_the_same_number_of_days_each_week? do
        option "same-number-of-days"
        option "different-number-of-days"

        on_response do
          self.calculator = Calculators::AgriculturalHolidayEntitlementCalculator.new
        end

        next_node do |response|
          case response
          when 'same-number-of-days'
            question :how_many_days_per_week?
          when 'different-number-of-days'
            question :what_date_does_holiday_start?
          end
        end
      end

      multiple_choice :how_many_days_per_week? do
        option "7-days"
        option "6-days"
        option "5-days"
        option "4-days"
        option "3-days"
        option "2-days"
        option "1-day"

        on_response do |response|
          # XXX: this is a bit nasty and takes advantage of the fact that
          # to_i only looks for the very first integer
          calculator.days_worked_per_week = response.to_i
        end

        next_node do
          question :worked_for_same_employer?
        end
      end

      date_question :what_date_does_holiday_start? do
        from { Date.civil(Date.today.year, 1, 1) }
        to { Date.civil(Date.today.year + 1, 12, 31) }

        on_response do |response|
          calculator.holiday_starts_on = response
        end

        next_node do
          question :how_many_total_days?
        end
      end

      multiple_choice :worked_for_same_employer? do
        option "same-employer"
        option "multiple-employers"

        next_node do |response|
          case response
          when 'same-employer'
            outcome :done
          when 'multiple-employers'
            question :how_many_weeks_at_current_employer?
          end
        end
      end

      value_question :how_many_total_days?, parse: Integer do
        on_response do |response|
          calculator.total_days_worked = response
        end

        validate { calculator.valid_total_days_worked? }

        next_node do
          question :worked_for_same_employer?
        end
      end

      value_question :how_many_weeks_at_current_employer?, parse: Integer do
        #Has to be less than a full year
        validate { calculator.valid_weeks_at_current_employer? }

        on_response do |response|
          calculator.weeks_at_current_employer = response
        end

        next_node do
          outcome :done_with_number_formatting
        end
      end

      outcome :done
      outcome :done_with_number_formatting
    end
  end
end
