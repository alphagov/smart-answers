status :draft

multiple_choice :name_of_institution? do
  option :uni_1 => :not_recognised
  option :uni_2 => :recognised
end

outcome :not_recognised
outcome :recognised
