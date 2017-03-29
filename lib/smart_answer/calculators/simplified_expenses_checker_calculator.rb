module SmartAnswer::Calculators
  class SimplifiedExpensesCheckerCalculator
    attr_accessor :home_costs
    attr_accessor :vehicle_costs
    attr_accessor :vehicle_price
    attr_accessor :type_of_vehicle
    attr_accessor :vehicle_emission
    attr_accessor :hours_worked_home
    attr_accessor :selected_allowance
    attr_accessor :new_or_used_vehicle
    attr_accessor :business_use_percent
    attr_accessor :business_miles_car_van
    attr_accessor :business_premises_cost
    attr_accessor :car_status_before_usage
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
      vehicle_is_dirty? ? (vehicle_price.to_f * 0.18) : nil
    end

    def filthy_vehicle_price
      # if filthy  => take 8% of user input/vehicle_price
      vehicle_is_filthy? ? (vehicle_price.to_f * 0.08) : nil
    end

    def green_vehicle_write_off
      if vehicle_is_green?
        money(green_vehicle_price * vehicle_business_use_time)
      end
    end

    def dirty_vehicle_write_off
      if vehicle_is_dirty?
        money(dirty_vehicle_price * vehicle_business_use_time)
      end
    end

    def filthy_vehicle_write_off
      if vehicle_is_filthy?
        money(filthy_vehicle_price * vehicle_business_use_time)
      end
    end

    def vehicle_write_off
      case
      when vehicle_is_green?
        green_vehicle_write_off.to_f
      when vehicle_is_dirty?
        dirty_vehicle_write_off.to_f
      when vehicle_is_filthy?
        filthy_vehicle_write_off.to_f
      else
        0
      end
    end

    def simple_total
      money(simple_vehicle_costs.to_f + simple_home_costs.to_f)
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

    def current_scheme_costs
      money(
        vehicle_costs.to_f +
        vehicle_write_off.to_f +
        home_costs.to_f
      )
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

    def capital_allowance?
      selected_allowance == "capital_allowance"
    end

    def simplified_expenses?
      selected_allowance == "simplified_expenses"
    end

    def no_allowance?
      selected_allowance == "no"
    end

    def capital_allowance_claimed?
      capital_allowance? && any_work_location?
    end

    def simplified_expenses_claimed?
      simplified_expenses? && any_work_location?
    end

    def capital_allowances_estimate
      if selected_allowance == "no"
        money(vehicle_write_off.to_f)
      else
        money(current_scheme_costs.to_f + simple_business_costs.to_f)
      end
    end

    def vehicle_is_green?
      vehicle_emission == "low" && new_car?
    end

    def vehicle_is_dirty?
      vehicle_emission == "medium" && car?
    end

    def vehicle_is_filthy?
      vehicle_emission == "high" && car?
    end

    def vehicle?
      (list_of_expenses & vehicles).any?
    end

    def vehicle_only?
      business_premises_expense == "no_expense" && vehicle?
    end

    def business_premises?
      business_premises_expense == "live_on_business_premises" && vehicle?
    end

    def home?
      business_premises_expense == "using_home_for_business" && vehicle?
    end

    def car?
      list_of_expenses.include?("car")
    end

    def new_car?
      car? && (car_status_before_usage == "new" ||
          new_or_used_vehicle == "new")
    end

    def used_car?
      car? && (car_status_before_usage == "used" ||
          new_or_used_vehicle == "used")
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

    def simple_vehicle_costs
      case
      when car? || van?
        simple_vehicle_costs_car_van.to_f
      when motorcycle?
        simple_vehicle_costs_motorcycle.to_f
      else
        0
      end
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
