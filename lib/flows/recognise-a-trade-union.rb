satisfies_need "B193"
section_slug "work"
status :draft

multiple_choice :what_do_you_need_to_do? do
  option :recognise_a_trade_union => :do_you_want_to_recognise_the_union_voluntarily?
  option :derecoognise_a_trade_union => :has_it_been_3_years_since_gaining_recognition?
end

multiple_choice :do_you_want_to_recognise_the_union_voluntarily? do
  option :yes => :you_agree_to_recognise_the_union
  option :no => :how_many_employees_do_you_have?
end

multiple_choice :how_many_employees_do_you_have? do
  option :"21_or_more" => :have_they_submitted_an_application?
  option :fewer_than_21 => :the_union_cannot_apply_for_statutory_recognition
end

multiple_choice :have_they_submitted_an_application? do
  option :yes => :no_action_required
  option :no => :have_cac_accepted_the_application?
end

multiple_choice :have_cac_accepted_the_application? do
  option :accepted => :agreed_on_bargaining_unit?
  option :rejected => :you_do_not_have_to_recognise_the_union_can_reapply
end

multiple_choice :agreed_on_bargaining_unit? do
  option :yes => :has_the_cac_ordered_a_ballot?
  option :no => :has_the_cac_ordered_a_ballot?
end

multiple_choice :has_the_cac_ordered_a_ballot? do
  option :declared_recognition => :you_agree_to_recognise_the_union
  option :ordered_ballot => :did_the_majority_support_the_union_in_the_ballot?
end

multiple_choice :did_the_majority_support_the_union_in_the_ballot? do
  option :yes => :you_agree_to_recognise_the_union
  option :no => :you_do_not_have_to_recognise_the_union_cannot_reapply
end

multiple_choice :has_it_been_3_years_since_gaining_recognition? do
  option :yes => :on_what_grounds_are_you_seeking_derecognition?
  option :no => :you_cannot_seek_derecognition
end

multiple_choice :on_what_grounds_are_you_seeking_derecognition? do
  option :lack_of_support_for_bargaining => :written_to_union?
  option :falling_union_membership => :does_the_union_agree_with_derecognition_falling_union_membership?
  option :reduced_workforce => :have_you_sent_notice?
end

multiple_choice :written_to_union? do
  option :yes => :does_the_union_agree_with_derecognition_lack_of_bargaining_support?
  option :no => :write_to_union2
end

multiple_choice :have_you_sent_notice? do
  option :yes => :is_your_derecognition_valid?
  option :no => :write_to_union
end

multiple_choice :does_the_union_agree_with_derecognition_lack_of_bargaining_support? do
  option :agree => :the_union_is_derecognised_and_bargaining_ends
  option :does_not_agree => :will_the_cac_hold_a_ballot_lack_of_bargaining_support?
end

multiple_choice :will_the_cac_hold_a_ballot_lack_of_bargaining_support? do
  option :hold_a_ballot => :what_is_the_cacs_decision_on_the_ballot?
  option :do_not_hold_a_ballot => :you_must_continue_with_the_existing_bargaining_arrangements
end

multiple_choice :does_the_union_agree_with_derecognition_falling_union_membership? do
  option :agree => :the_union_is_derecognised_and_bargaining_ends
  option :does_not_agree => :will_the_cac_hold_a_ballot_falling_union_membership?
end

multiple_choice :will_the_cac_hold_a_ballot_falling_union_membership? do
  option :hold_a_ballot => :what_is_the_cacs_decision_on_the_ballot?
  option :do_not_hold_a_ballot => :you_must_continue_with_the_existing_bargaining_arrangements
end

multiple_choice :what_is_the_cacs_decision_on_the_ballot? do
  option :end_collective_bargaining => :the_union_is_derecognised_and_bargaining_ends
  option :continue_collective_bargaining => :you_must_continue_with_the_existing_bargaining_arrangements
end

multiple_choice :is_your_derecognition_valid? do
  option :valid => :the_union_is_derecognised_and_bargaining_will_end
  option :not_valid => :you_cannot_seek_derecognition
end

outcome :you_agree_to_recognise_the_union
outcome :the_union_cannot_apply_for_statutory_recognition
outcome :no_action_required
outcome :you_do_not_have_to_recognise_the_union_can_reapply
outcome :you_cannot_seek_derecognition
outcome :the_union_is_derecognised_and_bargaining_ends
outcome :the_union_is_derecognised_and_bargaining_will_end
outcome :you_must_continue_with_the_existing_bargaining_arrangements
outcome :you_do_not_have_to_recognise_the_union_cannot_reapply
outcome :write_to_union
outcome :write_to_union2