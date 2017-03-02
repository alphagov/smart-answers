module SmartAnswer
  class SimplifiedExpensesCheckerFlow < Flow
    def define
      content_id "8ad76560-8a27-42ee-9a99-8aaa8f0109a5"
      name 'simplified-expenses-checker'
      status :published
      satisfies_need "100119"

      calculator = Calculators::SimplifiedExpensesCheckerCalculator.new

      #Q1 - vehicle expense
      multiple_choice :vehicle_expense? do
        option :car
        option :van
        option :motorbike
        option :no_vehicle

        next_node do |response|
          calculator.type_of_vehicle = response
          question :home_or_business_premises_expense?
        end
      end

      #Q2 - home or business premises expense
      multiple_choice :home_or_business_premises_expense? do
        option :using_home_for_business
        option :live_on_business_premises
        option :no_expense

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

        next_node do |response|
          calculator.new_or_used_vehicle = response

          if response == "new" || response == "used"
            question :is_vehicle_green?
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

        next_node do |response|
          calculator.selected_allowance = response
          case
          when calculator.capital_allowance?
            if calculator.vehicle_only?
              outcome :capital_allowance_result
            elsif calculator.home?
              question :hours_work_home?
            elsif calculator.business_premises?
              question :deduct_from_premises?
            end
          when calculator.simplified_expenses?
            if calculator.vehicle_only?
              outcome :you_cant_claim_capital_allowance
            elsif calculator.home?
              question :hours_work_home?
            elsif calculator.business_premises?
              question :deduct_from_premises?
            end
          when calculator.no_allowance?
            if calculator.van? || calculator.motorbike?
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

        next_node do |response|
          calculator.car_status_before_usage = response
          question :how_much_expect_to_claim?
        end
      end

      #Q6 - claim vehicle expenses
      money_question :how_much_expect_to_claim? do
        next_node do |response|
          calculator.vehicle_costs = response

          if calculator.car?
            question :is_vehicle_green?
          elsif calculator.van? || calculator.motorbike?
            question :price_of_vehicle?
          end
        end
      end

      #Q7 - is vehicle green?
      multiple_choice :is_vehicle_green? do
        option :yes
        option :no

        next_node do |response|
          calculator.no_vehicle_emission = response
          question :price_of_vehicle?
        end
      end

      #Q8 - price of vehicle
      money_question :price_of_vehicle? do
        next_node do |response|
          calculator.vehicle_price = response
          question :vehicle_business_use_time?
        end
      end

      #Q9 - vehicle private use time
      value_question :vehicle_business_use_time?, parse: :to_f do
        # deduct percentage amount from [green_cost] or [dirty_cost] and store as [green_write_off] or [dirty_write_off]

        next_node do |response|
          calculator.business_use_percent = response

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
        next_node do |response|
          calculator.business_miles_car_van = response.delete(",").to_f

          if calculator.motorbike?
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
        next_node do |response|
          calculator.business_miles_motorcycle = response.delete(",").to_f

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
        next_node do |response|
          calculator.hours_worked_home = response.delete(',').to_f
          hours = response.to_i

          if hours < 1
            raise SmartAnswer::InvalidResponse
          elsif hours < 25
            outcome :you_cant_use_result
          else
            question :current_claim_amount_home?
          end
        end
      end

      #Q13 - how much do you claim?
      money_question :current_claim_amount_home? do
        next_node do |response|
          calculator.home_costs = response

          if calculator.living_on_business_premises?
            question :deduct_from_premises?
          else
            outcome :you_can_use_result
          end
        end
      end

      #Q14 = how much do you deduct from premises for private use?
      money_question :deduct_from_premises? do
        save_input_as :business_premises_cost

        next_node do
          question :people_live_on_premises?
        end
      end

      #Q15 - people who live on business premises?
      value_question :people_live_on_premises?, parse: :to_i do
        next_node do |response|
          calculator.hours_lived_on_business_premises = response
          outcome :you_can_use_result
        end
      end

      outcome :you_cant_use_result
      outcome :you_can_use_result do
        precalculate :vehicle_is_green do
          calculator.vehicle_is_green?
        end

        precalculate :green_vehicle_price do
          calculator.green_vehicle_price
        end

        precalculate :dirty_vehicle_price do
          calculator.dirty_vehicle_price
        end

        precalculate :list_of_expenses do
          calculator.list_of_expenses
        end

        precalculate :is_over_limit do
          calculator.over_limit?
        end

        precalculate :capital_allowance_claimed do
          calculator.capital_allowance_claimed?
        end

        precalculate :simple_vehicle_costs do
          calculator.simple_vehicle_costs_car_van
        end

        precalculate :simple_motorcycle_costs do
          calculator.simple_vehicle_costs_motorcycle
        end

        precalculate :vehicle_costs do
          calculator.vehicle_costs
        end

        precalculate :vehicle_price do
          calculator.vehicle_price
        end

        precalculate :home_costs do
          calculator.home_costs
        end

        precalculate :green_vehicle_write_off do
          calculator.green_vehicle_write_off
        end

        precalculate :dirty_vehicle_write_off do
          calculator.dirty_vehicle_write_off
        end

        precalculate :simple_business_costs do
          calculator.simple_business_costs
        end

        precalculate :simple_home_costs do
          calculator.simple_home_costs
        end

        precalculate :simple_total do
          vehicle = simple_vehicle_costs.to_f
          motorcycle = simple_motorcycle_costs.to_f
          home = simple_home_costs.to_f

          Money.new(vehicle + motorcycle + home)
        end

        precalculate :current_scheme_costs do
          vehicle = vehicle_costs.to_f
          green = green_vehicle_write_off.to_f
          dirty = dirty_vehicle_write_off.to_f
          home = home_costs.to_f
          Money.new(vehicle + green + dirty + home)
        end

        precalculate :can_use_simple do
          simple_total > current_scheme_costs
        end
      end
      outcome :capital_allowance_result
      outcome :you_cant_claim_capital_allowance
    end
  end
end
