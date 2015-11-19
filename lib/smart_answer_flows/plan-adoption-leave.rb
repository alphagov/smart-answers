module SmartAnswer
  class PlanAdoptionLeaveFlow < Flow
    def define
      content_id "b0e80c8b-d19f-4a50-82f4-71ab08f88207"
      name 'plan-adoption-leave'
      status :published
      satisfies_need "101018"

      use_erb_templates_for_questions

      date_question :child_match_date? do
        save_input_as :match_date

        next_node :child_arrival_date?
      end

      date_question :child_arrival_date? do
        calculate :arrival_date do |response|
          raise InvalidResponse if response <= match_date
          response
        end

        next_node :leave_start?
      end

      date_question :leave_start? do
        calculate :start_date do |response|
          dist = (arrival_date - response).to_i
          raise InvalidResponse unless (1..14).include? dist
          response
        end

        calculate :calculator do
          Calculators::PlanAdoptionLeave.new(
            match_date: match_date,
            arrival_date: arrival_date,
            start_date: start_date)
        end

        next_node :adoption_leave_details
      end

      outcome :adoption_leave_details do
        precalculate :match_date_formatted do
          calculator.formatted_match_date
        end
        precalculate :arrival_date_formatted do
          calculator.formatted_arrival_date
        end
        precalculate :start_date_formatted do
          calculator.formatted_start_date
        end
        precalculate :distance_start do
          calculator.distance_start
        end
        precalculate :last_qualifying_week_formatted do
          calculator.last_qualifying_week_formatted
        end
        precalculate :earliest_start_formatted do
          calculator.earliest_start_formatted
        end
        precalculate :period_of_ordinary_leave do
          calculator.format_date_range calculator.period_of_ordinary_leave
        end
        precalculate :period_of_additional_leave do
          calculator.format_date_range calculator.period_of_additional_leave
        end
      end
    end
  end
end
