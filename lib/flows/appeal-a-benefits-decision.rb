satisfies_need "9999"
status :draft
section_slug "money-and-tax"

# Q1
multiple_choice :already_appealed_the_decision? do
  option :yes => :problem_with_tribunal_proceedure?
  option :no => :date_of_decision_letter?
end

# Q2
multiple_choice :problem_with_tribunal_proceedure? do
  option :missing_doc_or_not_present => :you_can_challenge_decision #A1
  option :mistake_in_law => :can_appeal_to_upper_tribunal #A2
  option :none => :cant_challenge_or_appeal #A3
end

# Q3
multiple_choice :date_of_decision_letter? do
  option :greater_than_thirteen_months_ago => :cant_challenge_or_appeal #A3
  option :less_than_thirteen_months_ago => :had_written_explanation?
end

multiple_choice :had_written_explanation? do
  #option :spoken_explanation => 
end

outcome :you_can_challenge_decision #A1
outcome :can_appeal_to_upper_tribunal #A2
outcome :cant_challenge_or_appeal #A3

