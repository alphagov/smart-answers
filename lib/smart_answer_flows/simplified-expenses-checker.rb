module SmartAnswer
  class SimplifiedExpensesCheckerFlow < Flow
    def define
      start_page_content_id "8ad76560-8a27-42ee-9a99-8aaa8f0109a5"
      flow_content_id "09f5f2b6-dc09-4594-8c2a-d907fed427d5"
      name "simplified-expenses-checker"
      status :published
      satisfies_need "100119"

      #Q1 - vehicle expense
      multiple_choice :vehicle_expense? do
        option :car
        option :van
        option :motorcycle
        option :no_vehicle

        on_response do |response|
          self.calculator = Calculators::SimplifiedExpensesCheckerCalculator.new
          calculator.type_of_vehicle = response
        end

        next_node do
          question :home_or_business_premises_expense?
        end
      end

      #Q2 - home or business premises expense
      multiple_choice :home_or_business_premises_expense? do
        option :using_home_for_business
        option :live_on_business_premises
        option :no_expense

        on_response do |response|
          calculator.business_premises_expense = response
        end

        next_node do |response|
          calculator.business_premises_expense = response
          if response == "no_expense" &&
              calculator.type_of_vehicle == "no_vehicle"
            outcome :you_cant_use_result
          else
            raise InvalidResponse if response =~ /live_on_business_premises.*?using_home_for_business/

            if calculator.vehicle?
              question :buying_new_vehicle?
            elsif calculator.working_from_home?
              question :hours_work_home?
            elsif calculator.living_on_business_premises?
              question :deduct_from_premises?
            end
          end
        end
      end

      #Q3 - buying new vehicle?
      multiple_choice :buying_new_vehicle? do
        option :new
        option :used
        option :no

        on_response do |response|
          calculator.new_or_used_vehicle = response
        end

        next_node do |response|
          if %w(new used).include?(response)
            question :how_much_expect_to_claim?
          else
            question :capital_allowances?
          end
        end
      end

      #Q4 - capital allowances claimed?
      # if yes => go to Result 3 if in Q1 only [car_van] and/or [motorcylce] was selected
      #
      # if yes and other expenses apart from cars and/or motorbikes selected in Q1 store as capital_allowance_claimed and add text to result (see result 2) and go to questions for other expenses, ie don’t go to Q4 & Q8
      #
      # if no go to Q4
      multiple_choice :capital_allowances? do
        option :capital_allowance
        option :simplified_expenses
        option :no

        on_response do |response|
          calculator.selected_allowance = response
        end

        next_node do |response|
          calculator.selected_allowance = response
          if calculator.capital_allowance?
            if calculator.vehicle_only?
              outcome :capital_allowance_result
            elsif calculator.home?
              question :hours_work_home?
            elsif calculator.business_premises?
              question :deduct_from_premises?
            end
          elsif calculator.simplified_expenses?
            if calculator.vehicle_only?
              outcome :you_cant_claim_capital_allowance
            elsif calculator.home?
              question :hours_work_home?
            elsif calculator.business_premises?
              question :deduct_from_premises?
            end
          elsif calculator.no_allowance?
            if calculator.van? || calculator.motorcycle?
              question :how_much_expect_to_claim?
            elsif calculator.car?
              question :car_status_before_usage?
            end
          end
        end
      end

      #Q5 - Was your car new or second-hand when you started using it for your business?
      multiple_choice :car_status_before_usage? do
        option :new
        option :used

        on_response do |response|
          calculator.car_status_before_usage = response
        end

        next_node do
          question :how_much_expect_to_claim?
        end
      end

      #Q6 - claim vehicle expenses
      money_question :how_much_expect_to_claim? do
        on_response do |response|
          calculator.vehicle_costs = response
        end

        next_node do
          if calculator.car?
            question :is_vehicle_green?
          elsif calculator.van? || calculator.motorcycle?
            question :price_of_vehicle?
          end
        end
      end

      #Q7 - is vehicle green?
      multiple_choice :is_vehicle_green? do
        option :low
        option :medium
        option :high

        on_response do |response|
          calculator.vehicle_emission = case response
                                        when "low"
                                          if calculator.new_car?
                                            response
                                          else
                                            "medium"
                                          end
                                        else
                                          response
                                        end
        end

        next_node do
          question :price_of_vehicle?
        end
      end

      #Q8 - price of vehicle
      money_question :price_of_vehicle? do
        on_response do |response|
          calculator.vehicle_price = response
        end

        next_node do
          question :vehicle_business_use_time?
        end
      end

      #Q9 - vehicle private use time
      value_question :vehicle_business_use_time?, parse: :to_f do
        # deduct percentage amount from [green_cost] or [dirty_cost] and store as [green_write_off] or [dirty_write_off]

        on_response do |response|
          calculator.business_use_percent = response
        end

        next_node do |response|
          raise InvalidResponse if response.to_i > 100

          if calculator.car? || calculator.van?
            question :drive_business_miles_car_van?
          else
            question :drive_business_miles_motorcycle?
          end
        end
      end

      #Q10 - miles to drive for business car_or_van
      value_question :drive_business_miles_car_van? do
        on_response do |response|
          calculator.business_miles_car_van = response
        end

        next_node do
          if calculator.motorcycle?
            question :drive_business_miles_motorcycle?
          elsif calculator.working_from_home?
            question :hours_work_home?
          elsif calculator.living_on_business_premises?
            question :deduct_from_premises?
          else
            outcome :you_can_use_result
          end
        end
      end

      #Q11 - miles to drive for business motorcycle
      value_question :drive_business_miles_motorcycle? do
        on_response do |response|
          calculator.business_miles_motorcycle = response
        end

        next_node do
          if calculator.working_from_home?
            question :hours_work_home?
          elsif calculator.living_on_business_premises?
            question :deduct_from_premises?
          else
            outcome :you_can_use_result
          end
        end
      end

      #Q12 - hours for home work
      value_question :hours_work_home? do
        on_response do |response|
          calculator.hours_worked_home = response
        end

        next_node do |response|
          if response.to_f < 1
            raise SmartAnswer::InvalidResponse
          elsif response.to_f < 25
            outcome :you_cant_use_result
          else
            question :current_claim_amount_home?
          end
        end
      end

      #Q13 - how much do you claim?
      money_question :current_claim_amount_home? do
        on_response do |response|
          calculator.home_costs = response
        end

        next_node do
          if calculator.living_on_business_premises?
            question :deduct_from_premises?
          else
            outcome :you_can_use_result
          end
        end
      end

      #Q14 = how much do you deduct from premises for private use?
      money_question :deduct_from_premises? do
        on_response do |response|
          calculator.business_premises_cost = response
        end

        next_node do
          question :people_live_on_premises?
        end
      end

      #Q15 - people who live on business premises?
      value_question :people_live_on_premises?, parse: :to_i do
        on_response do |response|
          calculator.hours_lived_on_business_premises = response
        end

        next_node do
          outcome :you_can_use_result
        end
      end

      outcome :you_cant_use_result
      outcome :you_can_use_result
      outcome :capital_allowance_result
      outcome :you_cant_claim_capital_allowance
    end
  end
end
