module SmartAnswer
  class CoronavirusEmployeeRiskAssessmentFlow < Flow
    def define
      name "coronavirus-employee-risk-assessment"
      start_page_content_id "450fb30a-2e70-4f78-b3c0-8ed2fa276033"
      flow_content_id "e1a58c2f-c609-4644-a631-d21dc57b8cd6"
      status :published

      # Questions
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
            question :where_do_you_work?
          end
        end
      end

      multiple_choice :where_do_you_work? do
        option :food_and_drink
        option :salon_parlour
        option :retail
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
            "holiday_accommodation",
            "libraries",
            "community_centre",
            "places_of_worship",
            "leisure_centre",
            "indoor_attraction",
            "outdoor_recreation",
            "museums_or_galleries",
            "cinema"
            question :is_your_workplace_an_exception?
          when "auction_house"
            question :is_your_workplace_an_auction_house?
          when
            "salon_parlour",
            "nightclubs_or_gambling",
            "indoor_recreation",
            "funfair",
            "indoor_visitor_centres"
            outcome :workplace_should_be_closed
          else
            question :are_you_shielding?
          end
        end
      end

      multiple_choice :is_your_workplace_an_exception? do
        option :yes
        option :no

        next_node do |response|
          work_in_retail = calculator.where_do_you_work == "retail"
          if response == "yes" && work_in_retail
            outcome :workplace_should_be_closed
          elsif response == "yes"
            question :are_you_shielding?
          elsif work_in_retail
            outcome :go_back_to_work
          else
            outcome :workplace_should_be_closed
          end
        end
      end

      multiple_choice :is_your_workplace_an_auction_house? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            question :are_you_shielding?
          else
            outcome :workplace_should_be_closed
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

        next_node do |response|
          if response == "yes"
            outcome :vulnerable_work_arrangements
          else
            question :do_you_live_with_someone_vulnerable?
          end
        end
      end

      multiple_choice :do_you_live_with_someone_vulnerable? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            outcome :keep_your_household_safe
          else
            question :have_childcare_responsibility?
          end
        end
      end

      multiple_choice :have_childcare_responsibility? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            outcome :help_with_childcare
          else
            outcome :go_back_to_work
          end
        end
      end

      # Outcomes
      outcome :work_from_home
      outcome :work_from_home_help
      outcome :workplace_should_be_closed
      outcome :shielding_work_arrangements
      outcome :vulnerable_work_arrangements
      outcome :keep_your_household_safe
      outcome :help_with_childcare
      outcome :go_back_to_work
    end
  end
end
