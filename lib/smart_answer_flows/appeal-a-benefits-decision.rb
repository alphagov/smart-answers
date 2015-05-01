status :draft
satisfies_need "100492"

decision_appeal_limit_in_months = 13

# Q1
multiple_choice :already_appealed_the_decision? do
  title "Has your appeal already been heard?"
  body <<-EndBody
If you've already had an appeal hearing and you disagree with the tribunal's decision, you may be able to:

* ask to have the decision cancelled (this is known as 'setting aside')
* make a further appeal to the Upper Tribunal
  EndBody

  option :yes, 'Yes'
  option :no,  'No'

  next_node do |response|
    case response
    when :yes
      :problem_with_tribunal_proceedure?
    when :no
      :date_of_decision_letter?
  end
end

# Q2
multiple_choice :problem_with_tribunal_proceedure? do
  title "Was there a problem with the way the tribunal was run, or do you think they made a mistake in the law?"
  body <<-EndBody
If you disagree with the tribunal's decision, you can ask to have it cancelled (set aside) if:

* you didn&apos;t get an important document about the hearing in time
* you couldn't go to the hearing even though you wanted to

If you think they made a mistake in the law, you can ask for permission to appeal to the Upper Tribunal.
  EndBody

  option :missing_doc_or_not_present, "Yes - missing document or you couldn't go"
  option :mistake_in_law,             "Yes - I think the tribunal made a mistake in the law"
  option :none,                       "No"

  next_node do |response|
    case response
    when :missing_doc_or_not_present
      :you_can_challenge_decision
    when :mistake_in_law
      :can_appeal_to_upper_tribunal
    when :none
      :cant_challenge_or_appeal
    end
  end
end

# Q3
date_question :date_of_decision_letter? do
  title "When did you get the decision letter?"
  body <<-EndBody
Whether or not you can appeal depends on how long ago you got the letter with the decision.

You normally have 1 month after you got the decision letter to start an appeal. You can never
appeal if more than 13 months have passed.
  EndBody
  from { 5.years.ago }
  to { Date.today }

  save_input_as :decision_letter_date

  next_node do |response|
    decision_date = Date.parse(response)
    appeal_expiry_date = decision_appeal_limit_in_months.months.since(decision_date)
    if Date.today < appeal_expiry_date
      :had_written_explanation?
    else
      :cant_challenge_or_appeal
    end
  end
end

# Q4
multiple_choice :had_written_explanation? do
  title "Have you had any other information explaining the decision?"
  body <<-EndBody
This includes:

* talking to someone at the benefits office who explained the decision, either on the phone or face to face
* a written 'statement of reasons' explaining the decision
  EndBody

  option :spoken_explanation,  "Yes, talked to someone"
  option :written_explanation, "Yes, had a written statement"
  option :no,                  "No"

  calculate :appeal_expiry_date do
    decision_date = Date.parse(decision_letter_date)
    if (decision_date > 1.month.ago.to_date)
      1.month.since(decision_date)
    end
  end

  calculate :appeal_expiry_text do
    if appeal_expiry_date
      "You have until #{appeal_expiry_date.to_s(:long)} to start an appeal."
    else
      ""
    end
  end

  next_node do |response|
    if response == 'written_explanation'
      :when_did_you_ask_for_it?
    else
      a_month_has_passed = (Date.parse(decision_letter_date) < 1.month.ago.to_date)
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
end

# Q5
date_question :when_did_you_ask_for_it? do
  title "When did you ask for the written statement?"
  body <<-EndBody
You might have longer to decide about appealing depending on:

* when you asked for the written statement
* when the benefits office sent it to you

If you&apos;re not sure when you asked for the written statement, your benefits office will be able to tell you. Contact them using the details on your decision letter.
  EndBody
  from { 5.years.ago }
  to { Date.today }

  calculate :written_explanation_request_date do
    Date.parse(responses.last).strftime("%e %B %Y")
  end

  next_node :when_did_you_get_it?
end

# Q6
date_question :when_did_you_get_it? do
  title "When did you get it?"
  body <<-EndBody
You might have longer to decide about appealing depending on:

* when you asked for the written statement
* when the benefits office sent it to you
  EndBody
  from { 5.years.ago }
  to { Date.today }
  error_message "Please enter a date on or after %{written_explanation_request_date}"

  save_input_as :written_explanation_received_date

  calculate :appeal_expiry_date do
    decision_date = Date.parse(decision_letter_date)
    received_date = Date.parse(responses.last)
    request_date = Date.parse(written_explanation_request_date)
    raise InvalidResponse if received_date < request_date
    received_within_a_month = received_date < 1.month.since(request_date)

    if received_within_a_month
      expiry_date = 1.fortnight.since(1.month.since(decision_date))
    else
      expiry_date = 1.fortnight.since(received_date)
    end
    if Date.today < expiry_date
      expiry_date
    end
  end

  calculate :appeal_expiry_text do
    if appeal_expiry_date
      "You have until #{appeal_expiry_date.to_s(:long)} to start an appeal"
    else
      ""
    end
  end

  next_node do |response|
    received_date = Date.parse(response)
    received_within_a_month = received_date < 1.month.since(Date.parse(written_explanation_request_date))
    a_fortnight_has_passed = Date.today > 1.fortnight.since(received_date)
    decision_date = Date.parse(decision_letter_date)
    a_month_and_a_fortnight_since_decision = Date.today > 1.fortnight.since(1.month.since(decision_date))

    if (!received_within_a_month and a_fortnight_has_passed) or
      (received_within_a_month and a_month_and_a_fortnight_since_decision)
      :special_circumstances?
    else
      :asked_to_reconsider?
    end
  end
end

# Q7
multiple_choice :special_circumstances? do
  title "Did something happen to stop you appealing when you first got the decision?"
  body <<-EndBody
You normally have 1 month after you got the decision to start an appeal, but you might
be able to ask for more time.

Contact the benefits office using the details on your decision letter if you couldn&apos;t
appeal because you were:

* in hospital or coping with illness
* coping with bereavement
* outside the UK
* couldn&apos;t send your appeal form (eg if there was a postal strike)
* affected by something else that meant you couldn’t appeal within a month

You might be able to:

- make a late appeal
- make a late request for the decision to be looked at again
  EndBody

  option :yes, 'Yes'
  option :no,  'No'

  next_node do |response|
    case response
    when :yes
      :asked_to_reconsider?
    when :no
      :cant_appeal
    end
  end
end

# Q8
multiple_choice :asked_to_reconsider? do
  title "Have you asked the benefits office to look at the decision again?"
  body <<-EndBody
Sometimes, the benefits office will change a decision about your benefits if you ask them to look at it again (reconsider).

You don&apos;t have to ask them to reconsider before you appeal. If you don't think you'll have enough time before the deadline, you might want to skip this stage and start an appeal straight away.

%{appeal_expiry_text}
  EndBody

  option :yes, "Yes, or want to skip this stage"
  option :no,  "No"

  next_node do |response|
    case response
    when :yes
      :kind_of_benefit_or_credit?
    when :no
      :ask_to_reconsider
    end
  end
end

# Q9
multiple_choice :kind_of_benefit_or_credit? do
  title "What kind of benefit or credit was the decision about?"
  body <<-EndBody
Social fund payments are: budgeting loans, community care grants, crisis loans or
social fund overpayments.


Other benefits and credits include 'social security' benefits like Income Support,
Jobseeker&apos;s Allowance, Incapacity Benefit, Employment Support Allowance, Disability
Living Allowance or Attendance Allowance.
  EndBody

  option :budgeting_loan,          "Social fund benefit"
  option :housing_benefit,         "Housing Benefit or Council Tax Benefit"
  option :child_benefit,           "Child Benefit or Guardian's Allowance"
  option :other_credit_or_benefit, "Any other benefit or credit"

  next_node do |response|
    case response
    when :budgeting_loan
      :apply_to_the_independent_review_service
    when :housing_benefit
      :appeal_to_your_council
    when :child_benefit
      :appeal_to_hmrc_ch24a
    when :other_credit_or_benefit
      :appeal_to_social_security
    end
  end
end

outcome :you_can_challenge_decision #A1
outcome :can_appeal_to_upper_tribunal #A2
outcome :cant_challenge_or_appeal #A3
outcome :ask_for_an_explanation #A4
outcome :cant_appeal #A5
outcome :ask_to_reconsider #A6
outcome :apply_to_the_independent_review_service #A7
#A8 - removed
outcome :appeal_to_your_council #A9
#A10 - removed
outcome :appeal_to_hmrc_ch24a #A11
outcome :appeal_to_social_security #A12
