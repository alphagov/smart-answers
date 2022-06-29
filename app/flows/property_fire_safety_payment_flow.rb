class PropertyFireSafetyPaymentFlow < SmartAnswer::Flow
  def define
    name "property-fire-safety-payment"
    content_id "29355604-e9a1-499a-9b0c-18abd833f02e"
    status :draft

    radio :building_over_11_metres? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :own_freehold?
        else
          outcome :unlikely_to_need_fixing
        end
      end
    end

    radio :own_freehold? do
      option :yes
      option :no

      next_node do |response|
        if response == "no"
          question :own_more_than_3_properties?
        else
          outcome :have_to_pay
        end
      end
    end

    radio :own_more_than_3_properties? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :main_home_february_2022?
        else
          question :year_of_purchase?
        end
      end
    end

    radio :main_home_february_2022? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :year_of_purchase?
        else
          outcome :have_to_pay
        end
      end
    end

    value_question :year_of_purchase?, parse: Integer do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::PropertyFireSafetyPaymentCalculator.new
        calculator.year_of_purchase = response.to_i
      end

      validate(:valid_year_of_purchase?) do
        calculator.valid_year_of_purchase?
      end

      next_node do
        question :value_of_property?
      end
    end

    money_question :value_of_property? do
      on_response do |response|
        calculator.value_of_property = response
      end

      next_node do
        question :live_in_london?
      end
    end

    radio :live_in_london? do
      option :yes
      option :no

      on_response do |response|
        calculator.live_in_london = response
      end

      next_node do
        question :shared_ownership?
      end
    end

    radio :shared_ownership? do
    end

    outcome :unlikely_to_need_fixing
    outcome :have_to_pay
  end
end
