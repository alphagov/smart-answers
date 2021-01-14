require "rails_helper"

RSpec.feature "SmartAnswer::AmIGettingMinimumWageFlow", type: :feature do
  let(:older_age) { 45 }
  let(:pay_frequency) { 20 }
  let(:working_hours_in_day) { 8 }
  let(:hours_worked) { pay_frequency * working_hours_in_day }
  let(:pay_above_minimum_wage) { 10_000 }
  let(:pay_below_minimum_wage) { 10 }
  let(:accommodation_charge) { 5 }
  let(:days_per_week_in_accommodation) { 5 }
  let(:under_age) { 14 }

  let(:shared_headings) do
    # <question name>: <text_for :title from erb>
    {
      flow_title: "National Minimum Wage and Living Wage calculator for workers",
      what_would_you_like_to_check: "What would you like to check?",
    }
  end

  before do
    stub_content_store_has_item("/am-i-getting-minimum-wage")
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

    scenario "Not apprentice, above minimum wage, no accommodation" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If you're getting the National Minimum Wage or the National Living Wage"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:are_you_an_apprentice))

      choose "Not an apprentice"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_are_you))

      fill_in "response", with: older_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_do_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_do_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_are_you_paid_during_pay_period))

      fill_in "response", with: pay_above_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:is_provided_with_accommodation))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:does_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Not apprentice, below minimum wage, with accommodation" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If you're getting the National Minimum Wage or the National Living Wage"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:are_you_an_apprentice))

      choose "Not an apprentice"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_are_you))

      fill_in "response", with: older_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_do_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_do_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_are_you_paid_during_pay_period))

      fill_in "response", with: pay_below_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:is_provided_with_accommodation))

      choose "Yes, the accommodation is charged for"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_accommodation_charge))

      fill_in "response", with: accommodation_charge
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_accommodation_usage))

      fill_in "response", with: days_per_week_in_accommodation
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:does_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Apprentice, above minimum wage" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If you're getting the National Minimum Wage or the National Living Wage"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:are_you_an_apprentice))

      choose "Apprentice under 19"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_do_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_do_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_are_you_paid_during_pay_period))

      fill_in "response", with: pay_below_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:is_provided_with_accommodation))

      choose "Yes, the accommodation is charged for"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_accommodation_charge))

      fill_in "response", with: accommodation_charge
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_accommodation_usage))

      fill_in "response", with: days_per_week_in_accommodation
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:does_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:current_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Under age" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If you're getting the National Minimum Wage or the National Living Wage"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:are_you_an_apprentice))

      choose "Not an apprentice"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_are_you))

      fill_in "response", with: under_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
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

    scenario "Not apprentice, above minimum wage, no accommodation" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If an employer owes you payments from last year (April 2019 to March 2020)"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:were_you_an_apprentice))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_were_you))

      fill_in "response", with: older_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_did_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_did_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_were_you_paid_during_pay_period))

      fill_in "response", with: pay_above_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:was_provided_with_accommodation))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:did_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Not apprentice, below minimum wage, with accommodation" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If an employer owes you payments from last year (April 2019 to March 2020)"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:were_you_an_apprentice))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_were_you))

      fill_in "response", with: older_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_did_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_did_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_were_you_paid_during_pay_period))

      fill_in "response", with: pay_below_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:was_provided_with_accommodation))

      choose "Yes, the accommodation was charged for"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_accommodation_charge))

      fill_in "response", with: accommodation_charge
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_accommodation_usage))

      fill_in "response", with: days_per_week_in_accommodation
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:did_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Apprentice, above minimum wage" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If an employer owes you payments from last year (April 2019 to March 2020)"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:were_you_an_apprentice))

      choose "Apprentice under 19"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_often_did_you_get_paid))

      fill_in "response", with: pay_frequency
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_many_hours_did_you_work))

      fill_in "response", with: hours_worked
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_much_were_you_paid_during_pay_period))

      fill_in "response", with: pay_below_minimum_wage
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:was_provided_with_accommodation))

      choose "Yes, the accommodation was charged for"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_accommodation_charge))

      fill_in "response", with: accommodation_charge
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_accommodation_usage))

      fill_in "response", with: days_per_week_in_accommodation
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:did_employer_charge_for_job_requirements))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:past_additional_work_outside_shift))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end

    scenario "Under age" do
      visit "/am-i-getting-minimum-wage"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))

      click_govuk_start_button
      expect(page).to have_selector("h1", text: headings.fetch(:what_would_you_like_to_check))

      choose "If an employer owes you payments from last year (April 2019 to March 2020)"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:were_you_an_apprentice))

      choose "No"
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:how_old_were_you))

      fill_in "response", with: under_age
      click_button "Continue"
      expect(page).to have_selector("h1", text: headings.fetch(:flow_title))
    end
  end
end
