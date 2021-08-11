class AdditionalCommodityCodeFlow < SmartAnswer::Flow
  def define
    content_id "bfda3b4f-166b-48e7-9aaf-21bfbd606207"
    name "additional-commodity-code"
    response_store :query_parameters

    status :published

    setup do
      self.calculator = SmartAnswer::Calculators::CommodityCodeCalculator.new
    end

    # Q1
    radio :starch_or_glucose do
      options do
        calculator.starch_or_glucose_options.keys
      end

      on_response do |response|
        calculator.starch_glucose_weight = response
      end

      next_node do
        question :sucrose
      end
    end

    radio :sucrose do
      options do
        calculator.sucrose_options.keys
      end

      on_response do |response|
        calculator.sucrose_weight = response
      end

      next_node do
        question :milk_fat
      end
    end

    # Q3
    radio :milk_fat do
      options do
        calculator.milk_fat_options.keys
      end

      on_response do |response|
        calculator.milk_fat_weight = response
      end

      next_node do |response|
        if response.to_i < 40
          question :milk_protein
        else
          outcome :commodity_code_result
        end
      end
    end

    radio :milk_protein do
      options do
        calculator.milk_protein_options.keys
      end

      on_response do |response|
        calculator.milk_protein_weight = response
      end

      next_node do
        outcome :commodity_code_result
      end
    end

    outcome :commodity_code_result
  end
end
