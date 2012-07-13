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
