module SmartAnswer
  class CoronavirusEmployeeRiskAssessmentFlow < Flow
    def define
      name "coronavirus-employee-risk-assessment"
      start_page_content_id "450fb30a-2e70-4f78-b3c0-8ed2fa276033"
      flow_content_id "e1a58c2f-c609-4644-a631-d21dc57b8cd6"
      status :draft

      # Questions
      multiple_choice :can_work_from_home? do
        option :yes
        option :maybe
        option :no

        on_response do |response|
          # We don't need to do any calculations right now
          #self.calculator = Calculators::CoronavirusEmployeeRiskAssessmentCalculator.new
          #calculator.can_work_from_home = response
        end

        next_node do |response|
          case response
            when "yes"
              outcome :work_from_home
            when "maybe"
              outcome :maybe_work_from_home
            when "no"
              question :where_do_you_work?
          end
        end
      end

      multiple_choice :where_do_you_work? do
        option :food_and_drink
        option :salon_parlour
        option :retail
        option :car_showroom
        option :outdoor_market
        option :auction_house
        option :other

        next_node do |response|
          # to be set 
        end
      end

      # Outcomes
      outcome :work_from_home
      outcome :maybe_work_from_home
    end
  end
end
