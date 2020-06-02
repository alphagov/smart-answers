module SmartAnswer
  class CoronavirusEmployeeRiskAssessmentFlow < Flow
    def define
      name "coronavirus-employee-risk-assessment"
      start_page_content_id "450fb30a-2e70-4f78-b3c0-8ed2fa276033"
      flow_content_id "e1a58c2f-c609-4644-a631-d21dc57b8cd6"
      status :draft

      multiple_choice :work_from_home? do
        option :yes
        option :maybe
        option :no

        on_response do |response|
          self.calculator = Calculators::CoronavirusEmployeeRiskAssessmentCalculator.new
          calculator.work_from_home = response
        end

        next_node do
          outcome :work_from_home
        end
      end

      outcome :results
    end
  end
end
