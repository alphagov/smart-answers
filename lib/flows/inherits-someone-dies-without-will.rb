satisfies_need 2006
section_slug "money-and-tax"
status :published

multiple_choice :do_you_have_a_living_spouse_or_civil_partner? do
  option yes: :is_your_estate_worth_more_than_250000?
  option :no => :do_you_have_children?
end

multiple_choice :do_you_have_children? do
  option yes: :shared_equally_between_children
  option :no => :are_either_of_your_parents_living?
end

multiple_choice :is_your_estate_worth_more_than_250000? do
  option :yes => :do_you_have_any_children?
  option no: :your_partner_receives_all_of_your_estate
end

multiple_choice :are_either_of_your_parents_living? do
  option yes: :shared_equally_between_parents
  option :no => :do_you_have_brothers_or_sisters?
end

multiple_choice :do_you_have_any_children? do
  option no: :do_you_have_any_parents_or_brothers_or_sisters_living?
  option :yes => :partner_receives_first_250000_children_receive_share_of_remainder
end

multiple_choice :do_you_have_brothers_or_sisters? do
  option yes: :shared_equally_between_brothers_or_sisters
  option :no => :do_you_have_grandparents_living?
end

multiple_choice :do_you_have_any_parents_or_brothers_or_sisters_living? do
  option yes: :partner_receives_first_450000_remainder_to_parents_or_siblings
  option no: :your_partner_receives_all_of_your_estate
end

multiple_choice :do_you_have_grandparents_living? do
  option yes: :shared_equally_between_grandparents
  option :no => :do_you_have_any_living_aunts_or_uncles?
end

multiple_choice :do_you_have_any_living_aunts_or_uncles? do
  option yes: :shared_equally_between_aunts_or_uncles
  option :no => :are_there_living_children_of_deceased_aunts_or_uncles?
end

multiple_choice :are_there_living_children_of_deceased_aunts_or_uncles? do
  option yes: :shared_equally_between_children_of_aunts_or_uncles
  option :no => :do_you_have_any_living_half_aunts_or_uncles?
end

multiple_choice :do_you_have_any_living_half_aunts_or_uncles? do
  option yes: :shared_equally_between_half_aunts_or_uncles
  option :no => :are_there_living_children_of_deceased_half_aunts_or_uncles?
end

multiple_choice :are_there_living_children_of_deceased_half_aunts_or_uncles? do
  option yes: :shared_equally_between_children_of_half_aunts_or_uncles
  option :no => :everything_goes_to_crown
end

outcome :shared_equally_between_children
outcome :shared_equally_between_parents
outcome :your_partner_receives_all_of_your_estate
outcome :partner_receives_first_250000_children_receive_share_of_remainder
outcome :shared_equally_between_brothers_or_sisters
outcome :shared_equally_between_grandparents
outcome :partner_receives_first_450000_remainder_to_parents_or_siblings
outcome :shared_equally_between_aunts_or_uncles
outcome :shared_equally_between_children_of_aunts_or_uncles
outcome :shared_equally_between_half_aunts_or_uncles
outcome :shared_equally_between_children_of_half_aunts_or_uncles
outcome :everything_goes_to_crown
