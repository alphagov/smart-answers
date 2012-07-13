satisfies_need "9999"
status :draft
section_slug "money-and-tax"

# Number of months after receiving a decision when a person can appeal.
#
APPEAL_LIMIT_IN_MONTHS = 13 unless defined? APPEAL_LIMIT_IN_MONTHS

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
date_question :date_of_decision_letter? do
  save_input_as :decision_letter_date
  next_node do |response|
    decision_date = Date.parse(response)
    appeal_expiry_date = decision_date >> APPEAL_LIMIT_IN_MONTHS
    
    if Date.today < appeal_expiry_date
      :had_written_explanation?
    else
      :cant_challenge_or_appeal
    end
  end
end

# Q4
multiple_choice :had_written_explanation? do
  option :written_explanation => :when_did_you_get_it?
  option :spoken_explanation
  option :no
  next_node do |response|
    a_month_has_passed = (Date.parse(decision_letter_date) < Date.today << 1)
    if a_month_has_passed
      :special_circumstances?
    else
      if response == 'spoken_explanation'
        :asked_to_reconsider?
      else
        :ask_for_an_explanation
      end
    end
  end
end

multiple_choice :asked_to_reconsider? do
end

multiple_choice :special_circumstances? do
end

outcome :you_can_challenge_decision #A1
outcome :can_appeal_to_upper_tribunal #A2
outcome :cant_challenge_or_appeal #A3
outcome :ask_for_an_explanation #A4
