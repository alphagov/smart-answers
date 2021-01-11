require "rails_helper"

RSpec.feature "CalculateEmployeeRedundancyPayFlow", type: :feature do
  let(:headings) do
    {
      flow_title: "Calculate your statutory redundancy pay",
      date_of_redundancy: "What date were you made redundant?",
      age_of_employee: "How old were you on the date you were made redundant?",
      years_employed: "How many years have you worked for your employer?",
      weekly_pay_before_tax: "What is your weekly pay before tax and any other deductions?",
      done: "Based on your answers, your statutory redundancy payment is",
      done_no_statutory: "Based on your answers, you’re not entitled to statutory redundancy pay.",
    }
  end

  let(:errors) do
    {
      age_of_employee: "Please enter an age between 16 and 100.",
      years_employed: "Please enter a number. Based on your previous answers this should be no greater than",
      weekly_pay_before_tax: "Please enter a number",
    }
  end

  let(:hints) do
    {
      date_of_redundancy: "Use the original redundancy date even if your notice is brought forward, you’re paid in lieu of notice or made redundant after trialing a new job.",
      years_employed: "Only count full years of service. For example, 3 years and 9 months count as 3 years.",
      weekly_pay_before_tax: "Examples of other deductions include student loans and child maintenance.",
    }
  end

  def start_the_flow
    visit "/calculate-your-redundancy-pay"
    expect(page).to have_selector("h1", text: headings[:flow_title])
    click_govuk_start_button

    expect(page).to have_selector("h1", text: headings[:date_of_redundancy])
    expect(page).to have_selector("div", text: hints[:date_of_redundancy])

    fill_in "response[day]", with: 10
    fill_in "response[month]", with: 10
    fill_in "response[year]", with: 2020

    click_button "Next step"
  end

  def given_an_employee_aged(age)
    expect(page).to have_selector("h1", text: headings[:age_of_employee])

    fill_in "response", with: age

    click_button "Next step"
  end

  def who_has_been_with_their_employer_for(years)
    expect(page).to have_selector("h1", text: headings[:years_employed])
    expect(page).to have_selector("div", text: hints[:years_employed])

    fill_in "response", with: years

    click_button "Next step"
  end

  def and_earns_a_weekly_age_of(pounds_per_week)
    expect(page).to have_selector("h1", text: headings[:weekly_pay_before_tax])
    expect(page).to have_selector("div", text: hints[:weekly_pay_before_tax])
    expect(page).to have_selector("div", text: "per week")

    fill_in "response", with: pounds_per_week

    click_button "Next step"
  end

  before do
    stub_content_store_has_item("/calculate-your-redundancy-pay")
  end

  context "employee is entitled to statutory redundancy pay" do
    scenario "a 50 year old employee is being made redundant after 10 years service and is paid £500 per week" do
      start_the_flow

      given_an_employee_aged 50
      who_has_been_with_their_employer_for 10
      and_earns_a_weekly_age_of 500

      expect(page).to have_selector("h2", text: headings[:done])
    end
  end

  context "employee is not entitled to statutory redundancy pay" do
    scenario "employee has been with their employer for less than 2 years" do
      start_the_flow

      given_an_employee_aged 50
      who_has_been_with_their_employer_for 1

      expect(page).to have_selector("h2", text: headings[:done_no_statutory])
    end
  end

  context "errors" do
    context "employee's age is not within the 16 to 100 age range" do
      scenario "employee is younger than 16" do
        start_the_flow

        given_an_employee_aged 15

        expect(page).to have_selector("span", text: errors[:age_of_employee])
      end

      scenario "employee is older than 100" do
        start_the_flow

        given_an_employee_aged 101

        expect(page).to have_selector("span", text: errors[:age_of_employee])
      end
    end

    scenario "employee has worked for more years than is possible" do
      start_the_flow

      given_an_employee_aged 50
      who_has_been_with_their_employer_for 36

      expect(page).to have_selector("span", text: errors[:years_employed])
    end

    scenario "employee did not give their weekly pay" do
      start_the_flow

      given_an_employee_aged 50
      who_has_been_with_their_employer_for 10
      and_earns_a_weekly_age_of nil

      expect(page).to have_selector("span", text: errors[:weekly_pay_before_tax])
    end
  end
end
