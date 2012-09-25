satisfies_need "B193"
status :draft

# Q1
multiple_choice :what_do_you_need_to_do? do
  option :recognise_a_trade_union => :do_you_want_to_recognise_the_union_voluntarily?
  option :derecognise_a_trade_union => :does_the_union_agree_with_derecognition_voluntarily?
end

# Q2
multiple_choice :do_you_want_to_recognise_the_union_voluntarily? do
  option :yes => :you_agree_to_recognise_the_union
  option :no => :how_many_employees_do_you_have?
end

# Q3
multiple_choice :how_many_employees_do_you_have? do
  option :"21_or_more" => :have_they_submitted_an_application?
  option :fewer_than_21 => :the_union_cannot_apply_for_statutory_recognition
end

# Q4
multiple_choice :have_they_submitted_an_application? do
  option :yes => :have_cac_accepted_the_application?
  option :no => :no_action_required
end

# Q5
multiple_choice :have_cac_accepted_the_application? do
  option :yes => :agreed_on_bargaining_unit?
  option :no => :you_do_not_have_to_recognise_the_union_can_reapply
end

# Q6
multiple_choice :agreed_on_bargaining_unit? do
  option :yes => :has_the_cac_ordered_a_ballot?
  option :no => :cac_decided_bargaining_unit?
end

## QX
multiple_choice :cac_decided_bargaining_unit? do
  option :yes => :has_the_cac_ordered_a_ballot?
  option :no => :cac_will_decide_bargaining_unit
end

# Q7
multiple_choice :has_the_cac_ordered_a_ballot? do
  option :declared_recognition => :you_must_recognise_the_union
  option :ordered_ballot => :did_the_majority_support_the_union_in_the_ballot?
end

# Q8
multiple_choice :did_the_majority_support_the_union_in_the_ballot? do
  option :yes => :you_must_recognise_the_union
  option :no => :you_do_not_have_to_recognise_the_union_cannot_reapply
end

## QY
multiple_choice :does_the_union_agree_with_derecognition_voluntarily? do
  option :yes => :union_voluntarily_derecognised
  option :no => :has_it_been_3_years_since_gaining_recognition?
end


# Q9
multiple_choice :has_it_been_3_years_since_gaining_recognition? do
  option :yes => :on_what_grounds_are_you_seeking_derecognition?
  option :no => :you_cannot_seek_derecognition
end

# Q10
multiple_choice :on_what_grounds_are_you_seeking_derecognition? do
  option :reduced_workforce => :have_you_sent_notice?
  option :lack_of_support_for_bargaining => :written_to_union?
  option :falling_union_membership => :written_to_union2?
end

# Q11
multiple_choice :have_you_sent_notice? do
  option :yes => :is_your_derecognition_valid?
  option :no => :write_to_union
end

# Q12
multiple_choice :is_your_derecognition_valid? do
  option :yes => :the_union_is_derecognised_and_bargaining_will_end
  option :no => :you_cannot_seek_derecognition
end

# Q13
multiple_choice :written_to_union? do
  option :yes => :does_the_union_agree_with_derecognition_lack_of_bargaining_support?
  option :no => :write_to_union2
end

# Q14
multiple_choice :does_the_union_agree_with_derecognition_lack_of_bargaining_support? do
  option :yes => :the_union_is_derecognised_and_bargaining_ends
  option :no => :will_the_cac_hold_a_ballot_lack_of_bargaining_support?
end

# Q15
multiple_choice :written_to_union2? do
  option :yes => :does_the_union_agree_with_derecognition_lack_of_bargaining_support?
  option :no => :write_to_union2
end

# Q16
multiple_choice :will_the_cac_hold_a_ballot_lack_of_bargaining_support? do
  option :yes => :what_is_the_cacs_decision_on_the_ballot?
  option :no => :you_must_continue_with_the_existing_bargaining_arrangements
end

# Q17
multiple_choice :what_is_the_cacs_decision_on_the_ballot? do
  option :yes => :majority_vote_to_end_collective_bargaining?
  option :no => :you_must_continue_with_the_existing_bargaining_arrangements
end

# Q18
multiple_choice :majority_vote_to_end_collective_bargaining? do
  option :yes => :the_union_is_derecognised_and_bargaining_ends
  option :no => :you_must_continue_with_the_existing_bargaining_arrangements
end


#A1
outcome :you_agree_to_recognise_the_union
#A2
outcome :the_union_cannot_apply_for_statutory_recognition
#A3
outcome :no_action_required
#A4
outcome :you_do_not_have_to_recognise_the_union_can_reapply
#A5
outcome :you_must_recognise_the_union
#A6
outcome :you_do_not_have_to_recognise_the_union_cannot_reapply
#AX
outcome :cac_will_decide_bargaining_unit


#A7
outcome :you_cannot_seek_derecognition
#A8
outcome :write_to_union

#AY 
outcome :union_voluntarily_derecognised

#A9
outcome :the_union_is_derecognised_and_bargaining_will_end
#A10
outcome :write_to_union2
#A11
outcome :the_union_is_derecognised_and_bargaining_ends
#A12
outcome :you_must_continue_with_the_existing_bargaining_arrangements
