class PlanAdoptionLeaveFlow < SmartAnswer::Flow
  def define
    content_id "b0e80c8b-d19f-4a50-82f4-71ab08f88207"
    name "plan-adoption-leave"
    status :published

    date_question :child_match_date? do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::PlanAdoptionLeave.new
        calculator.match_date = response
      end

      next_node do
        question :child_arrival_date?
      end
    end

    date_question :child_arrival_date? do
      on_response do |response|
        calculator.arrival_date = response
      end

      validate do
        calculator.valid_arrival_date?
      end

      next_node do
        question :leave_start?
      end
    end

    date_question :leave_start? do
      on_response do |response|
        calculator.start_date = response
      end

      validate do
        calculator.valid_start_date?
      end

      next_node do
        outcome :adoption_leave_details
      end
    end

    outcome :adoption_leave_details
  end
end
