require "rails_helper"

RSpec.feature "CalculateYourHolidayEntitlementFlow", type: :feature do
  let(:headings) do
    {
      flow_title: "Calculate holiday entitlement",
      basis_of_calculation: "Is the holiday entitlement based on:",
      calculation_period: "Do you want to work out holiday:",
      how_many_days_per_week: "Number of days worked per week?",
      what_is_your_starting_date: "What was the employment start date?",
      what_is_your_leaving_date: "What was the employment end date?",
      when_does_your_leave_year_start: "When does the leave year start?",
      how_many_hours_per_week: "Number of hours worked per week?",
      how_many_days_per_week_for_hours: "Number of days worked per week?",
      shift_worker_basis: "Do you want to calculate the holiday:",
      shift_worker_hours_per_shift: "How many hours in each shift?",
      shift_worker_shifts_per_shift_pattern: "How many shifts will be worked per shift pattern?",
      shift_worker_days_per_shift_pattern: "How many days in the shift pattern?",
    }
  end

  let(:basis_of_calucations) do
    {
      days_worked_per_week: "days worked per week",
      hours_worked_per_week: "hours worked per week",
      irregular_hours: "casual or irregular hours, including zero hours contracts",
      annualised_hours: "annualised hours",
      compressed_hours: "compressed hours",
      shift_worker: "shifts",
    }
  end

  let(:calculation_periods) do
    {
      full_year: "for a full leave year",
      starting: "for someone starting part way through a leave year",
      leaving: "for someone leaving part way through a leave year",
      starting_and_leaving: "for someone starting and leaving part way through a leave year",
    }
  end

  def start_the_flow
    visit "/calculate-your-holiday-entitlement"
    expect(page).to have_selector("h1", text: headings[:flow_title])
    click_link "Start now"
  end

  def basis_of_calculation(response)
    expect(page).to have_selector("h1", text: headings[:basis_of_calculation])
    choose response
    click_button "Continue"
  end

  def calculation_period(response)
    expect(page).to have_selector("h1", text: headings[:calculation_period])
    choose response
    click_button "Continue"
  end

  def calculation_period_shifts(response)
    expect(page).to have_selector("h1", text: headings[:shift_worker_basis])
    choose response
    click_button "Continue"
  end

  def how_many_days_per_week(response)
    expect(page).to have_selector("h1", text: headings[:how_many_days_per_week])
    fill_in "response", with: response
    click_button "Continue"
  end

  def what_is_your_starting_date(day, month, year)
    expect(page).to have_selector("h1", text: headings[:what_is_your_starting_date])
    fill_in "response[day]", with: day
    fill_in "response[month]", with: month
    fill_in "response[year]", with: year
    click_button "Continue"
  end

  def what_is_your_leaving_date(day, month, year)
    expect(page).to have_selector("h1", text: headings[:what_is_your_leaving_date])
    fill_in "response[day]", with: day
    fill_in "response[month]", with: month
    fill_in "response[year]", with: year
    click_button "Continue"
  end

  def when_does_your_leave_year_start(day, month, year)
    expect(page).to have_selector("h1", text: headings[:when_does_your_leave_year_start])
    fill_in "response[day]", with: day
    fill_in "response[month]", with: month
    fill_in "response[year]", with: year
    click_button "Continue"
  end

  def how_many_hours_per_week(response)
    expect(page).to have_selector("h1", text: headings[:how_many_hours_per_week])
    fill_in "response", with: response
    click_button "Continue"
  end

  def how_many_days_per_week_for_hours(response)
    expect(page).to have_selector("h1", text: headings[:how_many_days_per_week_for_hours])
    fill_in "response", with: response
    click_button "Continue"
  end

  def shift_worker_basis(response)
    expect(page).to have_selector("h1", text: headings[:shift_worker_basis])
    choose response
    click_button "Continue"
  end

  def shift_worker_hours_per_shift(response)
    expect(page).to have_selector("h1", text: headings[:shift_worker_hours_per_shift])
    fill_in "response", with: response
    click_button "Continue"
  end

  def shift_worker_shifts_per_shift_pattern(response)
    expect(page).to have_selector("h1", text: headings[:shift_worker_shifts_per_shift_pattern])
    fill_in "response", with: response
    click_button "Continue"
  end

  def shift_worker_days_per_shift_pattern(response)
    expect(page).to have_selector("h1", text: headings[:shift_worker_days_per_shift_pattern])
    fill_in "response", with: response
    click_button "Continue"
  end

  def statutory_entitlement(count, basis = "days")
    "The statutory holiday entitlement is #{count} #{basis} holiday."
  end

  def statutory_entitlement_shifts(shifts, hours)
    "The statutory holiday entitlement is #{shifts} shifts for the year. Each shift being #{hours} hours."
  end

  def statutory_entitlement_hours(hours)
    "The statutory entitlement is #{hours} hours holiday."
  end

  def statutory_entitlement_compressed(hours, minutes)
    "The statutory holiday entitlement is #{hours} hours and #{minutes} minutes holiday for the year. Rather than taking a day’s holiday it’s 8 hours and 0 minutes holiday for each day otherwise worked."
  end

  before do
    stub_content_store_has_item("/calculate-your-holiday-entitlement")
    start_the_flow
  end

  context "days-worked-per-week" do
    before do
      basis_of_calculation basis_of_calucations[:days_worked_per_week]
    end

    scenario "full-year" do
      calculation_period calculation_periods[:full_year]
      how_many_days_per_week 5
      expect(page).to have_selector("p", text: statutory_entitlement(28))
    end

    scenario "starting" do
      calculation_period calculation_periods[:starting]
      what_is_your_starting_date(14, 3, 2020)
      when_does_your_leave_year_start(2, 3, 2020)
      how_many_days_per_week 5
      expect(page).to have_selector("p", text: statutory_entitlement(28))
    end

    scenario "leaving" do
      calculation_period calculation_periods[:leaving]
      what_is_your_leaving_date(14, 7, 2020)
      when_does_your_leave_year_start(1, 1, 2020)
      how_many_days_per_week 5
      expect(page).to have_selector("p", text: statutory_entitlement(15))
    end

    scenario "starting-and-leaving" do
      calculation_period calculation_periods[:starting_and_leaving]
      what_is_your_starting_date(14, 7, 2020)
      what_is_your_leaving_date(14, 10, 2020)
      how_many_days_per_week 5
      expect(page).to have_selector("p", text: statutory_entitlement(7.2))
    end
  end # days-worked-per-week

  context "hours-worked-per-week" do
    before do
      basis_of_calculation basis_of_calucations[:hours_worked_per_week]
    end

    scenario "full-year" do
      calculation_period calculation_periods[:full_year]
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_hours(224))
    end

    scenario "starting" do
      calculation_period calculation_periods[:starting]
      what_is_your_starting_date(1, 6, 2020)
      when_does_your_leave_year_start(1, 1, 2020)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_hours(132))
    end

    scenario "leaving" do
      calculation_period calculation_periods[:leaving]
      what_is_your_leaving_date(1, 6, 2020)
      when_does_your_leave_year_start(1, 1, 2020)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_hours(93.7))
    end

    scenario "starting-and-leaving" do
      calculation_period calculation_periods[:starting_and_leaving]
      what_is_your_starting_date(20, 1, 2020)
      what_is_your_leaving_date(18, 7, 2020)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_hours(110.8))
    end
  end # hours-worked-per-week

  context "irregular-hours" do
    before do
      basis_of_calculation basis_of_calucations[:irregular_hours]
    end

    scenario "full-year" do
      calculation_period calculation_periods[:full_year]
      expect(page).to have_selector("p", text: statutory_entitlement(5.6, "weeks"))
    end

    scenario "starting" do
      calculation_period calculation_periods[:starting]
      what_is_your_starting_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(3.27, "weeks"))
    end

    scenario "leaving" do
      calculation_period calculation_periods[:leaving]
      what_is_your_leaving_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(2.35, "weeks"))
    end

    scenario "starting-and-leaving" do
      calculation_period calculation_periods[:starting_and_leaving]
      what_is_your_starting_date 20, 1, 2020
      what_is_your_leaving_date 18, 7, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(2.77, "weeks"))
    end
  end # irregular-hours

  context "annualised-hours" do
    before do
      basis_of_calculation basis_of_calucations[:annualised_hours]
    end

    scenario "full-year" do
      calculation_period calculation_periods[:full_year]
      expect(page).to have_selector("p", text: statutory_entitlement(5.6, "weeks"))
    end

    scenario "starting" do
      calculation_period calculation_periods[:starting]
      what_is_your_starting_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(3.27, "weeks"))
    end

    scenario "leaving" do
      calculation_period calculation_periods[:leaving]
      what_is_your_leaving_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(2.35, "weeks"))
    end

    scenario "starting-and-leaving" do
      calculation_period calculation_periods[:starting_and_leaving]
      what_is_your_starting_date 20, 1, 2020
      what_is_your_leaving_date 18, 7, 2020
      expect(page).to have_selector("p", text: statutory_entitlement(2.77, "weeks"))
    end
  end # annualised-hours

  context "compressed-hours" do
    before do
      basis_of_calculation basis_of_calucations[:compressed_hours]
    end

    scenario "full-year" do
      calculation_period calculation_periods[:full_year]
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_compressed(224, 0))
    end

    scenario "starting" do
      calculation_period calculation_periods[:starting]
      what_is_your_starting_date(1, 6, 2020)
      when_does_your_leave_year_start(1, 1, 2020)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_compressed(132, 0))
    end

    scenario "leaving - non-leap year" do
      calculation_period calculation_periods[:leaving]
      what_is_your_leaving_date(1, 6, 2019)
      when_does_your_leave_year_start(1, 1, 2019)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_compressed(93, 18))
    end

    scenario "starting-and-leaving - non-leap year" do
      calculation_period calculation_periods[:starting_and_leaving]
      what_is_your_starting_date(20, 1, 2019)
      what_is_your_leaving_date(18, 7, 2019)
      how_many_hours_per_week 40
      how_many_days_per_week_for_hours 5
      expect(page).to have_selector("p", text: statutory_entitlement_compressed(110, 30))
    end
  end # compressed-hours

  context "shift-worker" do
    before do
      basis_of_calculation basis_of_calucations[:shift_worker]
    end

    scenario "full-year" do
      calculation_period_shifts calculation_periods[:full_year]
      shift_worker_hours_per_shift 6
      shift_worker_shifts_per_shift_pattern 8
      shift_worker_days_per_shift_pattern 14
      expect(page).to have_selector("p", text: statutory_entitlement_shifts(22.4, 6.0))
    end

    scenario "starting" do
      calculation_period_shifts calculation_periods[:starting]
      what_is_your_starting_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      shift_worker_hours_per_shift 6
      shift_worker_shifts_per_shift_pattern 8
      shift_worker_days_per_shift_pattern 14
      expect(page).to have_selector("p", text: statutory_entitlement_shifts(13.5, 6.0))
    end

    scenario "leaving" do
      calculation_period_shifts calculation_periods[:leaving]
      what_is_your_leaving_date 1, 6, 2020
      when_does_your_leave_year_start 1, 1, 2020
      shift_worker_hours_per_shift 6
      shift_worker_shifts_per_shift_pattern 8
      shift_worker_days_per_shift_pattern 14
      expect(page).to have_selector("p", text: statutory_entitlement_shifts(9.37, 6.0))
    end

    scenario "starting-and-leaving" do
      calculation_period_shifts calculation_periods[:starting_and_leaving]
      what_is_your_starting_date 20, 1, 2020
      what_is_your_leaving_date 18, 7, 2020
      shift_worker_hours_per_shift 6
      shift_worker_shifts_per_shift_pattern 8
      shift_worker_days_per_shift_pattern 14
      expect(page).to have_selector("p", text: statutory_entitlement_shifts(11.08, 6.0))
    end
  end # shift-worker
end
