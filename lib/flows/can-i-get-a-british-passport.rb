status :draft

multiple_choice :do_you_have? do
  option :british_citizenship
  option :british_nationality
  option :british_partner
  option :british_parent

  next_node do |response|
    response == "British citizenship" ? :you_qualify : :is_one_of_these_true?
  end
end

multiple_choice :is_one_of_these_true? do
  option :born_in_uk
  option :born_in_british_colony
  option :naturalised
  option :uk_citizen_or_citizen_of_british_colony
  option :father_is_eligible
  option :none_of_the_above

  next_node do |response|
    if response == :none_of_the_above
      :you_lose
    else
      :date_of_birth
    end
  end
end

date_question :date_of_birth do
  save_input_as :dob

  next_node do |dob|
    if dob < Time.parse('1983-01-01')
      :yay
    else
      :nay
    end
  end
end


outcome :yay
outcome :nay
outcome :you_qualify
