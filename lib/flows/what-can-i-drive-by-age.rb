satisfies_need 9999
section_slug "family"
subsection_slug "driving"
status :draft

multiple_choice :how_old_are_you? do
  option "under-16"    => :age_under_16
  option "16"          => :are_you_getting_dla?
  option "17"          => :are_you_in_the_armed_forces?
  option "18"          => :are_you_in_the_armed_forces?
  option "19-20"       => :are_you_in_the_armed_forces?
  option "21"          => :age_21
  option "22-plus"     => :age_22_and_over

  save_input_as :age
end

multiple_choice :are_you_getting_dla? do
  option "dla"    => :age_16_with_dla
  option "no-dla" => :age_16
end

multiple_choice :are_you_in_the_armed_forces? do
  option "armed-forces"
  option "not-armed-forces"

  next_node do |response|
    if response == "armed-forces"
      :age_17_20_armed_forces
    else
      "age_#{age.underscore}".to_sym
    end
  end
end

outcome :age_under_16
outcome :age_16_with_dla
outcome :age_16
outcome :age_17
outcome :age_18
outcome :age_19_20
outcome :age_21
outcome :age_22_and_over
outcome :age_17_20_armed_forces
