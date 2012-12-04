satisfies_need 2006
status :draft

multiple_choice :where_did_the_deceased_live? do
  option :'england-and-wales'
  option :'northern-ireland'
  option :'scotland'

  save_input_as :region
  next_node :is_there_a_living_spouse_or_civil_partner?
end

multiple_choice :is_there_a_living_spouse_or_civil_partner? do
  save_input_as :living_spouse_partner
  option :yes => :is_the_estate_worth_more_than_250000?
  option :no => :are_there_living_children?

  next_node do |response|
    if region == "scotland"
      :are_there_living_children?
    else
      response == "yes" ? :is_the_estate_worth_more_than_250000? : :are_there_living_children?
    end
  end
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
        case region
        when "england-and-wales" then :partner_receives_first_250000_children_receive_half_of_remainder
        when "scotland" then :partner_receives_first_437000_children_receive_two_thirds_of_remainder
        when "northern-ireland" then :more_than_one_child?
        end
      else
        :shared_equally_between_children
      end
    else
      :are_there_living_parents?
    end
  end
end

multiple_choice :more_than_one_child? do
  option :yes => :partner_receives_first_250000_children_receive_two_thirds_of_remainder
  option :no => :partner_receives_first_250000_children_receive_half_of_remainder
end

multiple_choice :are_there_living_parents? do
  option :yes
  option :no
  save_input_as :living_parents

  next_node do |response|
    if response == "yes"
      if living_spouse_partner == "yes"
        case region
        when "england-and-wales" then :partner_receives_first_450000_remainder_to_parents_or_siblings
        when "scotland" then :are_there_any_brothers_or_sisters_living?
        when "northern-ireland" then :partner_receives_first_450000_parents_receive_half_of_remainder
        end
      else
        case region
        when "england-and-wales" then :shared_equally_between_parents
        when "scotland" then :are_there_any_brothers_or_sisters_living?
        when "northern-ireland" then :shared_equally_between_parents
        end
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
        case region
        when "england-and-wales" then :partner_receives_first_450000_remainder_shared_equally_between_brothers_or_sisters
        when "scotland"
          living_parents == "yes" ? :partner_receives_first_437000_remainder_split_between_parents_and_siblings : :partner_receives_first_437000_remainder_to_siblings
        when "northern-ireland" then :partner_receives_first_450000_siblings_receive_half_of_remainder
        end
      else
        case region
        when "england-and-wales" then :shared_equally_between_brothers_or_sisters
        when "northern-ireland" then :shared_equally_between_brothers_or_sisters
        when "scotland" then
          living_parents == "yes" ? :shared_equally_between_parents_and_siblings : :shared_equally_between_brothers_or_sisters
        end
      end
    else
      if living_spouse_partner == "yes"
        case region
        when "england-and-wales" then :partner_receives_all_of_the_estate
        when "northern-ireland" then :partner_receives_all_of_the_estate
        when "scotland"
          living_parents == "yes" ? :partner_receives_first_437000_remainder_to_parents : :partner_receives_all_of_the_estate
        end
      else
        case region
        when "england-and-wales" then :are_there_half_blood_brothers_or_sisters?
        when "northern-ireland" then :are_there_any_living_aunts_or_uncles?
        when "scotland" then
          living_parents == "yes" ? :shared_equally_between_parents : :are_there_any_living_aunts_or_uncles?
        end
      end
    end
  end
end

multiple_choice :are_there_half_blood_brothers_or_sisters? do
  option :yes => :shared_equally_between_half_blood_brothers_sisters
  option :no => :are_there_grandparents_living?
end

multiple_choice :are_there_grandparents_living? do
  option :yes
  option :no

  next_node do |response|
    if response == "yes"
      :shared_equally_between_grandparents
    else
      case region
      when "england-and-wales" then :are_there_any_living_aunts_or_uncles?
      when "scotland" then :are_there_any_living_great_aunts_or_uncles?
      when "northern-ireland" then :everything_goes_to_next_of_kin_or_crown
      end
    end
  end
end

multiple_choice :are_there_any_living_aunts_or_uncles? do
  option :yes
  option :no

  next_node do |response|
    if response == "yes"
      :shared_equally_between_aunts_or_uncles
    else
      case region
      when "england-and-wales" then :are_there_any_living_half_aunts_or_uncles?
      when "scotland" then :are_there_grandparents_living?
      when "northern-ireland" then :are_there_grandparents_living?
      end
    end
  end
end

multiple_choice :are_there_any_living_half_aunts_or_uncles? do
  option :yes => :shared_equally_between_half_aunts_or_uncles
  # TODO: Check
  option :no => :everything_goes_to_crown
end

multiple_choice :are_there_any_living_great_aunts_or_uncles? do
  option :yes => :shared_equally_between_great_aunts_or_uncles
  option :no => :everything_goes_to_crown
end

outcome :partner_receives_all_of_the_estate

outcome :partner_receives_first_250000_children_receive_half_of_remainder
outcome :partner_receives_first_250000_children_receive_two_thirds_of_remainder

outcome :partner_receives_first_437000_children_receive_two_thirds_of_remainder
outcome :partner_receives_first_437000_remainder_split_between_parents_and_siblings
outcome :partner_receives_first_437000_remainder_to_siblings
outcome :partner_receives_first_437000_remainder_to_parents

outcome :partner_receives_first_450000_remainder_shared_equally_between_brothers_or_sisters
outcome :partner_receives_first_450000_remainder_to_parents_or_siblings
outcome :partner_receives_first_450000_parents_receive_half_of_remainder
outcome :partner_receives_first_450000_siblings_receive_half_of_remainder

outcome :shared_equally_between_children
outcome :shared_equally_between_parents
outcome :shared_equally_between_parents_and_siblings
outcome :shared_equally_between_brothers_or_sisters
outcome :shared_equally_between_half_blood_brothers_sisters
outcome :shared_equally_between_grandparents
outcome :shared_equally_between_aunts_or_uncles
outcome :shared_equally_between_half_aunts_or_uncles
outcome :shared_equally_between_great_aunts_or_uncles

outcome :everything_goes_to_crown
outcome :everything_goes_to_next_of_kin_or_crown
