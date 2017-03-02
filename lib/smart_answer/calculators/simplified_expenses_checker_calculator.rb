module SmartAnswer::Calculators
  class SimplifiedExpensesCheckerCalculator
    attr_accessor :home_costs
    attr_accessor :vehicle_costs
    attr_accessor :vehicle_price
    attr_accessor :type_of_vehicle
    attr_accessor :hours_worked_home
    attr_accessor :capital_allowance
    attr_accessor :no_vehicle_emission
    attr_accessor :new_or_used_vehicle
    attr_accessor :business_use_percent
    attr_accessor :business_miles_car_van
    attr_accessor :business_premises_expense
    attr_accessor :business_miles_motorcycle
    attr_accessor :hours_lived_on_business_premises

    def list_of_expenses
      [type_of_vehicle, business_premises_expense] & selectable_expenses
    end

    def selectable_expenses
      vehicles + work_locations + none_options
    end

    def green_vehicle_price
      # if green => take user input/vehicle_price
      vehicle_is_green? ? vehicle_price.to_f : nil
    end

    def dirty_vehicle_price
      # if dirty  => take 18% of user input/vehicle_price
      vehicle_is_green? ? nil : (vehicle_price.to_f * 0.18)
    end

    def green_vehicle_write_off
      if vehicle_is_green?
        money(green_vehicle_price * vehicle_business_use_time)
      end
    end

    def dirty_vehicle_write_off
      unless vehicle_is_green?
        money(dirty_vehicle_price * vehicle_business_use_time)
      end
    end

    def simple_home_costs
      amount = case hours_worked_home.to_f
               when 0..24 then 0
               when 25..50 then 120
               when 51..100 then 216
               else 312
               end
      money(amount)
    end

    def simple_business_costs
      amount = case hours_lived_on_business_premises.to_f
               when 0 then 0
               when 1 then 4200
               when 2 then 6000
               else 7800
               end

      money(amount)
    end

    def simple_vehicle_costs_motorcycle
      money(business_miles_motorcycle.to_f * 0.24)
    end

    def simple_vehicle_costs_car_van
      # Calculation:
      # [user input 1-10,000] x 0.45
      # [user input > 10,001]  x 0.25
      if business_miles_car_van.to_f <= 10000
        money(business_miles_car_van.to_f * 0.45)
      else
        answer_over_amount = (business_miles_car_van.to_f - 10000) * 0.25
        money(4500.0 + answer_over_amount)
      end
    end

    def over_limit?
      # if input > 250k store as [over_van_limit]
      vehicle_price.to_f > 250000.0
    end

    def capital_allowance_claimed?
      capital_allowance == "yes" && any_work_location?
    end

    def vehicle_is_green?
      no_vehicle_emission == "yes"
    end

    def vehicle?
      (list_of_expenses & vehicles).any?
    end

    def car?
      list_of_expenses.include?("car")
    end

    def van?
      list_of_expenses.include?("van")
    end

    def motorcycle?
      list_of_expenses.include?("motorcycle")
    end

    def working_from_home?
      list_of_expenses.include?(work_locations.first)
    end

    def living_on_business_premises?
      list_of_expenses.include?(work_locations.last)
    end

    def any_work_location?
      (list_of_expenses & work_locations).any?
    end

  private

    def money(value)
      SmartAnswer::Money.new(value)
    end

    def vehicle_business_use_time
      (business_use_percent.to_f / 100.0)
    end

    def vehicles
      %w(car van motorcycle)
    end

    def none_options
      %w(no_vehicle no_expense)
    end

    def work_locations
      %w(using_home_for_business live_on_business_premises)
    end
  end
end
