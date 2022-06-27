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
    end

    outcome :unlikely_to_need_fixing
  end
end
