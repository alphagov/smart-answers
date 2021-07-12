RSpec.feature "AmIGettingMinimumWageFlow" do
  let(:shared_headings) do
    # <question name>: <text_for :title from erb>
    {
      flow_title: "National Minimum Wage and Living Wage calculator for workers",
      what_would_you_like_to_check: "What would you like to check?",
    }
  end

  let(:answers) do
    {
      older_age: 45,
      pay_frequency: 20,
      working_hours_in_day: 8,
      hours_worked: 20 * 8,
      pay_above_minimum_wage: 10_000,
      pay_below_minimum_wage: 10,
      accommodation_charge: 5,
      days_per_week_in_accommodation: 5,
      under_age: 14,
      apprentice: "Apprentice under 19",
      not_apprentice: "Not an apprentice",
      no: "No",
      yes_is_charged: "Yes, the accommodation is charged for",
      yes_was_charged: "Yes, the accommodation was charged for",
      wage: "If you're getting the National Minimum Wage or the National Living Wage",
      owed: "If an employer owes you payments from last year (April 2020 to March 2021)",
    }
  end

  before do
    stub_content_store_has_item("/am-i-getting-minimum-wage")
    start(the_flow: headings[:flow_title], at: "am-i-getting-minimum-wage")
  end

  context "Current payment" do
    let(:headings) do
      {
        are_you_an_apprentice: "Are you an apprentice?",
        how_old_are_you: "How old are you?",
        how_often_do_you_get_paid: "How often do you get paid?",
        how_many_hours_do_you_work: "How many hours do you work during the pay period?",
        how_much_are_you_paid_during_pay_period: "How much do you get paid before tax in the pay period?",
        is_provided_with_accommodation: "Does your employer provide you with accommodation?",
        current_accommodation_charge: "How much does your employer charge for accommodation per day?",
        current_accommodation_usage: "How many days per week do you live in the accommodation?",
        does_employer_charge_for_job_requirements: "Does your employer take money from your pay for things you need for your job?",
        current_additional_work_outside_shift: "Do you work additional time outside your shift?",
      }.merge(shared_headings)
    end

    before do
      answer(question: headings[:what_would_you_like_to_check], of_type: :radio, with: answers[:wage])
    end

    context "Not an apprentice" do
      before do
        answer(question: headings[:are_you_an_apprentice], of_type: :radio, with: answers[:not_apprentice])
        answer(question: headings[:how_old_are_you], of_type: :value, with: answers[:older_age])
        answer(question: headings[:how_often_do_you_get_paid], of_type: :value, with: answers[:pay_frequency])
        answer(question: headings[:how_many_hours_do_you_work], of_type: :value, with: answers[:hours_worked])
      end

      scenario "above minimum wage, no accommodation" do
        answer(question: headings[:how_much_are_you_paid_during_pay_period], of_type: :value, with: answers[:pay_above_minimum_wage])
        answer(question: headings[:is_provided_with_accommodation], of_type: :radio, with: answers[:no])
        answer(question: headings[:does_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
        answer(question: headings[:current_additional_work_outside_shift], of_type: :radio, with: answers[:no])

        ensure_page_has(header: headings[:flow_title])
      end

      scenario "below minimum wage, with accommodation" do
        answer(question: headings[:how_much_are_you_paid_during_pay_period], of_type: :value, with: answers[:pay_below_minimum_wage])
        answer(question: headings[:is_provided_with_accommodation], of_type: :radio, with: answers[:yes_is_charged])
        answer(question: headings[:current_accommodation_charge], of_type: :value, with: answers[:accommodation_charge])
        answer(question: headings[:current_accommodation_usage], of_type: :value, with: answers[:days_per_week_in_accommodation])
        answer(question: headings[:does_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
        answer(question: headings[:current_additional_work_outside_shift], of_type: :radio, with: answers[:no])

        ensure_page_has(header: headings[:flow_title])
      end
    end

    scenario "Apprentice, above minimum wage" do
      answer(question: headings[:are_you_an_apprentice], of_type: :radio, with: answers[:apprentice])
      answer(question: headings[:how_often_do_you_get_paid], of_type: :value, with: answers[:pay_frequency])
      answer(question: headings[:how_many_hours_do_you_work], of_type: :value, with: answers[:hours_worked])
      answer(question: headings[:how_much_are_you_paid_during_pay_period], of_type: :value, with: answers[:pay_below_minimum_wage])
      answer(question: headings[:is_provided_with_accommodation], of_type: :radio, with: answers[:yes_is_charged])
      answer(question: headings[:current_accommodation_charge], of_type: :value, with: answers[:accommodation_charge])
      answer(question: headings[:current_accommodation_usage], of_type: :value, with: answers[:days_per_week_in_accommodation])
      answer(question: headings[:does_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
      answer(question: headings[:current_additional_work_outside_shift], of_type: :radio, with: answers[:no])

      ensure_page_has(header: headings[:flow_title])
    end

    scenario "Under age" do
      answer(question: headings[:are_you_an_apprentice], of_type: :radio, with: answers[:not_apprentice])
      answer(question: headings[:how_old_are_you], of_type: :value, with: answers[:under_age])

      ensure_page_has(header: headings[:flow_title])
    end
  end

  context "Past payment" do
    let(:headings) do
      {
        were_you_an_apprentice: "Were you an apprentice at the time?",
        how_old_were_you: "How old were you at the time?",
        how_often_did_you_get_paid: "How often did you get paid?",
        how_many_hours_did_you_work: "How many hours did you work during the pay period?",
        how_much_were_you_paid_during_pay_period: "How much were you paid in the pay period?",
        was_provided_with_accommodation: "Did your employer provide you with accommodation?",
        past_accommodation_charge: "How much did your employer charge for accommodation per day?",
        past_accommodation_usage: "How many days per week did you live in the accommodation?",
        did_employer_charge_for_job_requirements: "Did your employer take money from your pay for things you needed for your job?",
        past_additional_work_outside_shift: "Did you work additional time outside your shift?",
      }.merge(shared_headings)
    end

    before do
      answer(question: headings[:what_would_you_like_to_check], of_type: :radio, with: answers[:owed])
    end

    context "Not an apprentice" do
      before do
        answer(question: headings[:were_you_an_apprentice], of_type: :radio, with: answers[:no])
        answer(question: headings[:how_old_were_you], of_type: :value, with: answers[:older_age])
        answer(question: headings[:how_often_did_you_get_paid], of_type: :value, with: answers[:pay_frequency])
        answer(question: headings[:how_many_hours_did_you_work], of_type: :value, with: answers[:hours_worked])
      end

      scenario "above minimum wage, no accommodation" do
        answer(question: headings[:how_much_were_you_paid_during_pay_period], of_type: :value, with: answers[:pay_above_minimum_wage])
        answer(question: headings[:was_provided_with_accommodation], of_type: :radio, with: answers[:no])
        answer(question: headings[:did_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
        answer(question: headings[:past_additional_work_outside_shift], of_type: :radio, with: answers[:no])

        ensure_page_has(header: headings[:flow_title])
      end

      scenario "below minimum wage, with accommodation" do
        answer(question: headings[:how_much_were_you_paid_during_pay_period], of_type: :value, with: answers[:pay_below_minimum_wage])
        answer(question: headings[:was_provided_with_accommodation], of_type: :radio, with: answers[:yes_was_charged])
        answer(question: headings[:past_accommodation_charge], of_type: :value, with: answers[:accommodation_charge])
        answer(question: headings[:past_accommodation_usage], of_type: :value, with: answers[:days_per_week_in_accommodation])
        answer(question: headings[:did_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
        answer(question: headings[:past_additional_work_outside_shift], of_type: :radio, with: answers[:no])

        ensure_page_has(header: headings[:flow_title])
      end
    end

    scenario "Apprentice, above minimum wage" do
      answer(question: headings[:were_you_an_apprentice], of_type: :radio, with: answers[:apprentice])
      answer(question: headings[:how_often_did_you_get_paid], of_type: :value, with: answers[:pay_frequency])
      answer(question: headings[:how_many_hours_did_you_work], of_type: :value, with: answers[:hours_worked])
      answer(question: headings[:how_much_were_you_paid_during_pay_period], of_type: :value, with: answers[:pay_below_minimum_wage])
      answer(question: headings[:was_provided_with_accommodation], of_type: :radio, with: answers[:yes_was_charged])
      answer(question: headings[:past_accommodation_charge], of_type: :value, with: answers[:accommodation_charge])
      answer(question: headings[:past_accommodation_usage], of_type: :value, with: answers[:days_per_week_in_accommodation])
      answer(question: headings[:did_employer_charge_for_job_requirements], of_type: :radio, with: answers[:no])
      answer(question: headings[:past_additional_work_outside_shift], of_type: :radio, with: answers[:no])

      ensure_page_has(header: headings.fetch(:flow_title))
    end

    scenario "Under age" do
      answer(question: headings[:were_you_an_apprentice], of_type: :radio, with: answers[:no])
      answer(question: headings[:how_old_were_you], of_type: :value, with: answers[:under_age])

      ensure_page_has(header: headings[:flow_title])
    end
  end
end
