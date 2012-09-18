status :draft
section_slug "international-trade"
satisfies_need "B659"

# Q1
multiple_choice :how_much_starch_glucose? do
  option 0
  option 5
  option 25
  option 50
  option 75
  
  save_input_as :starch_glucose_weight
  
  next_node do |response|
    case response.to_i
      when 25
        :how_much_sucrose_2?
      when 50
        :how_much_sucrose_3?
      when 75
        :how_much_sucrose_4?
      else
        :how_much_sucrose_1?
    end
  end
end

# Q2ab
multiple_choice :how_much_sucrose_1? do
  option 0
  option 5
  option 30
  option 50
  option 75

  save_input_as :sucrose_weight  
  next_node :how_much_milk_fat?
end

# Q2c
multiple_choice :how_much_sucrose_2? do
  option 0
  option 5
  option 30
  option 50

  save_input_as :sucrose_weight  
  next_node :how_much_milk_fat?
end

# Q2d
multiple_choice :how_much_sucrose_3? do
  option 0
  option 5
  option 30

  save_input_as :sucrose_weight  
  next_node :how_much_milk_fat?
end

# Q2e
multiple_choice :how_much_sucrose_4? do
  option 0
  option 5

  save_input_as :sucrose_weight  
  next_node :how_much_milk_fat?
end

# Q3
multiple_choice :how_much_milk_fat? do
  option 0
  option 1
  option 3
  option 6
  option 9
  option 12
  option 18
  option 26
  option 40
  option 55
  option 70
  option 85
  
  calculate :calculator do
    Calculators::CommodityCodeCalculator.new(
      starch_glucose_weight: starch_glucose_weight,
      sucrose_weight: sucrose_weight,
      milk_fat_weight: responses.last,
      milk_protein_weight: 0)
  end
  
  calculate :commodity_code do
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  
  save_input_as :milk_fat_weight
  
  next_node do |response|
    case response.to_i
      when 0, 1
        :how_much_milk_protein_ab?
      when 3
        :how_much_milk_protein_c?
      when 6
        :how_much_milk_protein_d?
      when 9, 12
        :how_much_milk_protein_ef?
      when 18, 26
        :how_much_milk_protein_gh?
      else
        :commodity_code_result
      end
  end
end

# Q3ab
multiple_choice :how_much_milk_protein_ab? do
  option 0
  option 2
  option 6
  option 18
  option 30
  option 60
  
  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end  
  next_node :commodity_code_result
end

# Q3c
multiple_choice :how_much_milk_protein_c? do
  option 0
  option 2
  option 12

  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3d
multiple_choice :how_much_milk_protein_d? do
  option 0
  option 4
  option 15
  
  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3ef
multiple_choice :how_much_milk_protein_ef? do
  option 0
  option 6
  option 18
  
  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

# Q3gh
multiple_choice :how_much_milk_protein_gh? do
  option 0
  option 6
  
  calculate :commodity_code do
    calculator.milk_protein_weight = responses.last.to_i
    calculator.commodity_code
  end
  calculate :conditional_result do
    if commodity_code == 'X'
      PhraseList.new(:result_with_no_commodity_code)
    else
      PhraseList.new(:result_with_commodity_code)
    end
  end
  next_node :commodity_code_result
end

outcome :commodity_code_result
