status :draft
section_slug "money-and-tax"
satisfies_need "2013"

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
end

# Q2c
multiple_choice :how_much_sucrose_2? do
  option 0
  option 5
  option 30
  option 50
end

# Q2d
multiple_choice :how_much_sucrose_3? do
  option 0
  option 5
  option 30
end

# Q2e
multiple_choice :how_much_sucrose_4? do
  option 0
  option 5
end

