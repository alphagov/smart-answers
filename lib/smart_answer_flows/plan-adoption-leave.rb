module SmartAnswer
  class PlanAdoptionLeaveFlow < Flow
    def define
      start_page_content_id "b0e80c8b-d19f-4a50-82f4-71ab08f88207"
      flow_content_id "a2ae6c66-ce83-4da1-b758-f7f12acc4c39"
      name "plan-adoption-leave"
      status :published
      satisfies_need "558b11d4-e164-40e2-96a2-f20643fe4539"

      date_question :child_match_date? do
        on_response do |response|
          self.calculator = Calculators::PlanAdoptionLeave.new
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
end
