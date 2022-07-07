class PropertyFireSafetyPaymentFlow < SmartAnswer::Flow
  def define
    name "check-fire-safety-costs"
    content_id "29355604-e9a1-499a-9b0c-18abd833f02e"
    status :draft

    radio :building_over_11_metres? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :owned_by_leaseholders?
        else
          outcome :unlikely_to_need_to_pay
        end
      end
    end

    radio :owned_by_leaseholders? do
      option :yes
      option :no

      next_node do |response|
        if response == "no"
          question :own_more_than_3_properties?
        else
          outcome :have_to_pay_owned_by_leaseholders
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
          question :purchased_pre_or_post_february_2022?
        end
      end
    end

    radio :main_home_february_2022? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          question :purchased_pre_or_post_february_2022?
        else
          outcome :have_to_pay_not_main_home
        end
      end
    end

    radio :purchased_pre_or_post_february_2022? do
      option :pre_feb_2022
      option :post_feb_2022

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::PropertyFireSafetyPaymentCalculator.new
        calculator.purchased_pre_or_post_february_2022 = response
      end

      next_node do
        question :year_of_purchase?
      end
    end

    value_question :year_of_purchase?, parse: Integer do
      on_response do |response|
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
      option :yes
      option :no

      on_response do |response|
        calculator.shared_ownership = response
      end

      next_node do |response|
        if response == "yes"
          question :percentage_owned?
        else
          outcome :payment_amount
        end
      end
    end

    value_question :percentage_owned?, parse: Float do
      on_response do |response|
        calculator.percentage_owned = response / 100
      end

      validate(:valid_percentage_owned?) do
        calculator.valid_percentage_owned?
      end

      next_node do
        outcome :payment_amount
      end
    end

    outcome :unlikely_to_need_to_pay
    outcome :have_to_pay_owned_by_leaseholders
    outcome :have_to_pay_not_main_home
    outcome :payment_amount
  end
end
