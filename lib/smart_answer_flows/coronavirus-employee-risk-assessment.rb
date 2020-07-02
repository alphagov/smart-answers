module SmartAnswer
  class CoronavirusEmployeeRiskAssessmentFlow < Flow
    def define
      name "coronavirus-employee-risk-assessment"
      start_page_content_id "450fb30a-2e70-4f78-b3c0-8ed2fa276033"
      flow_content_id "e1a58c2f-c609-4644-a631-d21dc57b8cd6"
      status :published

      # Questions
      multiple_choice :where_do_you_work? do
        option :food_and_drink
        option :salon_parlour
        option :retail
        option :driving_schools
        option :auction_house
        option :holiday_accommodation
        option :libraries
        option :community_centre
        option :places_of_worship
        option :museums_or_galleries
        option :nightclubs_or_gambling
        option :cinema
        option :leisure_centre
        option :indoor_attraction
        option :indoor_visitor_centres
        option :indoor_recreation
        option :funfair
        option :outdoor_recreation
        option :other

        on_response do |response|
          self.calculator = Calculators::CoronavirusEmployeeRiskAssessmentCalculator.new
          calculator.where_do_you_work = response
        end

        next_node do |response|
          case response
          when
            "food_and_drink",
            "retail",
            "driving_schools",
            "holiday_accommodation",
            "libraries",
            "community_centre",
            "places_of_worship",
            "leisure_centre",
            "indoor_attraction",
            "outdoor_recreation",
            "museums_or_galleries",
            "cinema",
            "auction_house"
            question :is_your_workplace_an_exception?
          when "other"
            question :can_work_from_home?
          else
            question :is_your_employer_asking_you_to_work?
          end
        end
      end

      multiple_choice :is_your_workplace_an_exception? do
        option :yes
        option :no

        on_response do |response|
          workplace_is_exception = response == "yes"

          # Responses for the retail exception question are the opposite
          if calculator.where_do_you_work == "retail"
            workplace_is_exception = !workplace_is_exception
          end

          calculator.workplace_is_exception = workplace_is_exception
        end

        next_node do |_response|
          if calculator.workplace_is_exception
            question :can_work_from_home?
          else
            question :is_your_employer_asking_you_to_work?
          end
        end
      end

      multiple_choice :is_your_employer_asking_you_to_work? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            question :can_work_from_home?
          else
            outcome :you_should_not_be_going_to_work
          end
        end
      end

      multiple_choice :can_work_from_home? do
        option :yes
        option :maybe
        option :no

        next_node do |response|
          case response
          when "yes"
            outcome :work_from_home
          when "maybe"
            outcome :work_from_home_help
          when "no"
            question :are_you_shielding?
          end
        end
      end

      multiple_choice :are_you_shielding? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            outcome :shielding_work_arrangements
          else
            question :are_you_vulnerable?
          end
        end
      end

      multiple_choice :are_you_vulnerable? do
        option :yes
        option :no

        on_response do |response|
          calculator.are_you_vulnerable = response
        end

        next_node do
          question :do_you_live_with_someone_vulnerable?
        end
      end

      multiple_choice :do_you_live_with_someone_vulnerable? do
        option :yes
        option :no

        on_response do |response|
          calculator.do_you_live_with_someone_vulnerable = response
        end

        next_node do
          question :have_childcare_responsibility?
        end
      end

      multiple_choice :have_childcare_responsibility? do
        option :yes
        option :no

        on_response do |response|
          calculator.have_childcare_responsibility = response
        end

        next_node do
          outcome :go_back_to_work
        end
      end

      # Outcomes
      outcome :you_should_not_be_going_to_work
      outcome :work_from_home
      outcome :work_from_home_help
      outcome :shielding_work_arrangements
      outcome :go_back_to_work
    end
  end
end
