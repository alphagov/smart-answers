satisfies_need 2006
section_slug "family"
subsection_slug "death-and-bereavement"
status :published


multiple_choice :is_there_a_living_spouse_or_civil_partner? do
  save_input_as :living_spouse_partner
  option :yes => :is_the_estate_worth_more_than_250000?
  option :no => :are_there_living_children?
end

multiple_choice :is_the_estate_worth_more_than_250000? do
  option :yes => :are_there_living_children?
  option :no => :partner_receives_all_of_the_estate
end

multiple_choice :are_there_living_children? do
  option :yes
  option :no

  next_node do |response|
    if response == "yes"
      if living_spouse_partner == "yes"
        :partner_receives_first_250000_children_receive_share_of_remainder
      else
        :shared_equally_between_children
      end
    else
      :are_there_living_parents?
    end
  end
end

multiple_choice :are_there_living_parents? do
  option :yes
  option :no

  next_node do |response|
    if response == "yes"
      if living_spouse_partner == "yes"
        :partner_receives_first_450000_remainder_to_parents_or_siblings
      else
        :shared_equally_between_parents
      end
    else
      :are_there_any_brothers_or_sisters_living?
    end
  end
end

multiple_choice :are_there_any_brothers_or_sisters_living? do
  option :yes
  option :no

  next_node do |response|
    if response == "yes"
      if living_spouse_partner == "yes"
        :partner_receives_first_450000_remainder_shared_equally_between_brothers_or_sisters
      else
        :shared_equally_between_brothers_or_sisters
      end
    else
      if living_spouse_partner == "yes"
        :partner_receives_all_of_the_estate
      else
        :are_there_half_blood_brothers_or_sisters?
      end
    end
  end
end

multiple_choice :are_there_half_blood_brothers_or_sisters? do
  option :yes => :shared_equally_between_half_blood_brothers_sisters
  option :no => :are_there_grandparents_living?
end

multiple_choice :are_there_grandparents_living? do
  option :yes => :shared_equally_between_grandparents
  option :no => :are_there_any_living_aunts_or_uncles?
end

multiple_choice :are_there_any_living_aunts_or_uncles? do
  option :yes => :shared_equally_between_aunts_or_uncles
  option :no => :are_there_any_living_half_aunts_or_uncles?
end

multiple_choice :are_there_any_living_half_aunts_or_uncles? do
  option :yes => :shared_equally_between_half_aunts_or_uncles
  # TODO: Check
  option :no => :everything_goes_to_crown
end


outcome :partner_receives_all_of_the_estate
outcome :shared_equally_between_children
outcome :shared_equally_between_parents
outcome :partner_receives_first_250000_children_receive_share_of_remainder
outcome :partner_receives_first_450000_remainder_shared_equally_between_brothers_or_sisters
outcome :shared_equally_between_brothers_or_sisters
outcome :shared_equally_between_half_blood_brothers_sisters
outcome :shared_equally_between_grandparents
outcome :partner_receives_first_450000_remainder_to_parents_or_siblings
outcome :shared_equally_between_aunts_or_uncles
outcome :shared_equally_between_half_aunts_or_uncles
outcome :everything_goes_to_crown
