module SmartAnswer
  class SimplifiedExpensesCheckerFlow < Flow
    def define
      name 'simplified-expenses-checker'
      status :published
      satisfies_need "100119"

      #Q1 - new or existing business
      multiple_choice :claimed_expenses_for_current_business? do
        option :yes
        option :no

        save_input_as :new_or_existing_business

        calculate :is_new_business do
          new_or_existing_business == "no"
        end

        calculate :is_existing_business do
          !is_new_business
        end

        next_node :type_of_expense?
      end

      #Q2 - type of expense
      checkbox_question :type_of_expense? do
        option :car_or_van
        option :motorcycle
        option :using_home_for_business
        option :live_on_business_premises

        calculate :list_of_expenses do |response|
          response == "none" ? [] : response.split(",")
        end

        next_node do |response|
          next_question = nil
          if response == "none"
            :you_cant_use_result
          else
            responses = response.split(",")
            raise InvalidResponse if response =~ /live_on_business_premises.*?using_home_for_business/
            if (responses & ["car_or_van", "motorcycle"]).any?
              :buying_new_vehicle?
            elsif responses.include?("using_home_for_business")
              :hours_work_home?
            elsif responses.include?("live_on_business_premises")
              :deduct_from_premises?
            end
          end
        end
      end

      #Q3 - buying new vehicle?
      multiple_choice :buying_new_vehicle? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_vehicle_green?
          else
            if is_existing_business
              :capital_allowances?
            else
              :how_much_expect_to_claim?
            end
          end
        end
      end

      #Q4 - capital allowances claimed?
      # if yes => go to Result 3 if in Q2 only [car_van] and/or [motorcylce] was selected
      #
      # if yes and other expenses apart from cars and/or motorbikes selected in Q2 store as capital_allowance_claimed and add text to result (see result 2) and go to questions for other expenses, ie don’t go to Q5 & Q9
      #
      # if no go to Q5
      multiple_choice :capital_allowances? do
        option :yes
        option :no

        calculate :capital_allowance_claimed do |response|
          response == "yes" and (list_of_expenses & %w(using_home_for_business live_on_business_premises)).any?
        end

        next_node do |response|
          if response == "yes"
            if (list_of_expenses & %w(using_home_for_business live_on_business_premises)).any?
              if list_of_expenses.include?("using_home_for_business")
                # Q11
                :hours_work_home?
              else
                # Q13
                :deduct_from_premises?
              end
            else
              :capital_allowance_result
            end
          else
            :how_much_expect_to_claim?
          end
        end
      end

      #Q5 - claim vehicle expenses
      money_question :how_much_expect_to_claim? do
        save_input_as :vehicle_costs

        next_node do
          if list_of_expenses.include?("car_or_van")
            :drive_business_miles_car_van?
          else
            :drive_business_miles_motorcycle?
          end
        end
      end

      #Q6 - is vehicle green?
      multiple_choice :is_vehicle_green? do
        option :yes
        option :no

        calculate :vehicle_is_green do |response|
          response == "yes"
        end

        next_node :price_of_vehicle?
      end

      #Q7 - price of vehicle
      money_question :price_of_vehicle? do
        # if green => take user input and store as [green_cost]
        # if dirty  => take 18% of user input and store as [dirty_cost]
        # if input > 250k store as [over_van_limit]
        save_input_as :vehicle_price

        calculate :green_vehicle_price do
          vehicle_is_green ? vehicle_price : nil
        end

        calculate :dirty_vehicle_price do
          vehicle_is_green ? nil : (vehicle_price * 0.18)
        end

        calculate :is_over_limit do
          vehicle_price > 250000.0
        end

        next_node :vehicle_business_use_time?
      end

      #Q8 - vehicle private use time
      value_question :vehicle_business_use_time?, parse: :to_f do
        # deduct percentage amount from [green_cost] or [dirty_cost] and store as [green_write_off] or [dirty_write_off]
        calculate :business_use_percent do |response|
          response
        end
        calculate :green_vehicle_write_off do
          vehicle_is_green ? Money.new(green_vehicle_price * (business_use_percent / 100)) : nil
        end

        calculate :dirty_vehicle_write_off do
          vehicle_is_green ? nil : Money.new(dirty_vehicle_price * (business_use_percent / 100))
        end

        next_node do |response|
          raise InvalidResponse if response.to_i > 100
          list_of_expenses.include?("car_or_van") ?
            :drive_business_miles_car_van? : :drive_business_miles_motorcycle?
        end
      end

      #Q9 - miles to drive for business car_or_van
      value_question :drive_business_miles_car_van? do
        # Calculation:
        # [user input 1-10,000] x 0.45
        # [user input > 10,001]  x 0.25
        calculate :simple_vehicle_costs do |response|
          answer = response.gsub(",", "").to_f
          if answer <= 10000
            Money.new(answer * 0.45)
          else
            answer_over_amount = (answer - 10000) * 0.25
            Money.new(4500.0 + answer_over_amount)
          end
        end
        next_node do
          if list_of_expenses.include?("motorcycle")
            :drive_business_miles_motorcycle?
          elsif list_of_expenses.include?("using_home_for_business")
            :hours_work_home?
          elsif list_of_expenses.include?("live_on_business_premises")
            :deduct_from_premises?
          else
            :you_can_use_result
          end
        end
      end

      #Q10 - miles to drive for business motorcycle
      value_question :drive_business_miles_motorcycle? do
        calculate :simple_motorcycle_costs do |response|
          Money.new(response.gsub(",", "").to_f * 0.24)
        end
        next_node do
          if list_of_expenses.include?("using_home_for_business")
            :hours_work_home?
          elsif list_of_expenses.include?("live_on_business_premises")
            :deduct_from_premises?
          else
            :you_can_use_result
          end
        end
      end

      #Q11 - hours for home work
      value_question :hours_work_home? do
        calculate :hours_worked_home do |response|
          response.gsub(",", "").to_f
        end

        calculate :simple_home_costs do
          amount = case hours_worked_home
                   when 0..24 then 0
                   when 25..50 then 120
                   when 51..100 then 216
                   else 312
                   end
          Money.new(amount)
        end

        next_node do |response|
          hours = response.to_i
          if hours < 1
            raise SmartAnswer::InvalidResponse
          elsif hours < 25
            :you_cant_use_result
          else
            :current_claim_amount_home?
          end
        end
      end

      #Q12 - how much do you claim?
      money_question :current_claim_amount_home? do
        save_input_as :home_costs

        next_node do
          list_of_expenses.include?("live_on_business_premises") ? :deduct_from_premises? : :you_can_use_result
        end
      end

      #Q13 = how much do you deduct from premises for private use?
      money_question :deduct_from_premises? do
        save_input_as :business_premises_cost

        next_node :people_live_on_premises?
      end

      #Q14 - people who live on business premises?
      value_question :people_live_on_premises?, parse: :to_i do
        calculate :live_on_premises do |response|
          response
        end

        calculate :simple_business_costs do
          amount = case live_on_premises
                   when 0 then 0
                   when 1 then 4200
                   when 2 then 6000
                   else 7800
                   end

          Money.new(amount)
        end

        next_node :you_can_use_result
      end

      use_outcome_templates

      outcome :you_cant_use_result
      outcome :you_can_use_result do
        precalculate :capital_allowance_claimed do
          capital_allowance_claimed
        end

        precalculate :simple_vehicle_costs do
          simple_vehicle_costs
        end

        precalculate :simple_motorcycle_costs do
          simple_motorcycle_costs
        end

        precalculate :vehicle_costs do
          vehicle_costs
        end

        precalculate :home_costs do
          home_costs
        end

        precalculate :green_vehicle_write_off do
          green_vehicle_write_off
        end

        precalculate :dirty_vehicle_write_off do
          dirty_vehicle_write_off
        end

        precalculate :simple_business_costs do
          simple_business_costs
        end

        precalculate :is_over_limit do
          is_over_limit
        end

        precalculate :simple_total do
          vehicle = simple_vehicle_costs.to_f || 0
          motorcycle = simple_motorcycle_costs.to_f || 0
          home = simple_home_costs.to_f || 0

          Money.new(vehicle + motorcycle + home)
        end

        precalculate :current_scheme_costs do
          vehicle = vehicle_costs.to_f || 0
          green = green_vehicle_write_off.to_f || 0
          dirty = dirty_vehicle_write_off.to_f || 0
          home = home_costs.to_f || 0
          Money.new(vehicle + green + dirty + home)
        end

        precalculate :can_use_simple do
          simple_total > current_scheme_costs
        end
      end
      outcome :capital_allowance_result
    end
  end
end
