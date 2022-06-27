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
    end

    value_question :year_of_purchase?, parse: Integer do
    end

    outcome :unlikely_to_need_fixing
    outcome :have_to_pay
  end
end
