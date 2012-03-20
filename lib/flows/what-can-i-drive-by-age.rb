satisfies_need 9999
section_slug "family"
subsection_slug "driving"
status :draft

multiple_choice :how_old_are_you? do
  option "under-16"    => :age_under_16
  option "16"          => :age_16_are_you_getting_dla?
  option "17"          => :age_17_are_you_in_the_armed_forces?
  option "18"          => :age_18_are_you_in_the_armed_forces?
  option "19-20"       => :age_19_20_are_you_in_the_armed_forces?
  option "21"          => :age_21
  option "22-plus"     => :age_22_and_over
end

multiple_choice :age_16_are_you_getting_dla? do
  option "dla"    => :age_16_with_dla
  option "no-dla" => :age_16
end

outcome :age_under_16
outcome :age_16_with_dla
outcome :age_16
outcome :age_21
outcome :age_22_and_over

%w[ 17 18 19_20 ].each do |age|
  multiple_choice "age_#{age}_are_you_in_the_armed_forces?".to_sym do
    option "armed-forces"     => :age_17_20_armed_forces
    option "not-armed-forces" => "age_#{age}".to_sym
  end

  outcome "age_#{age}".to_sym
end
outcome :age_17_20_armed_forces
