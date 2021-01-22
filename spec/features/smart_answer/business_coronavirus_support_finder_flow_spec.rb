require "rails_helper"

RSpec.feature "SmartAnswer::BusinessCoronavirusSupportFinderFlow", type: :feature do
  let(:headings) do
    # <question name>: <text_for :title from erb>
    {
      flow_title: "Find coronavirus financial support for your business",
      annual_turnover: "What is your annual turnover?",
      business_based: "Where is your business based?",
      business_size: "How many employees does your business have?",
      non_domestic_property: "What is the rateable value of your business' non-domestic property?",
      paye_scheme: "Are you an employer with a PAYE scheme?",
      sectors: "Select your type of business",
      self_assessment_july_2020: "Are you due to pay a Self Assessment payment on account by 31 July 2020?",
      self_employed: "Are you self-employed?",
      what_size_was_your_buisness: "What size was your business as of 28 February?",
      closed_by_restrictions: "Has your business closed by law because of coronavirus?",
      results: "Support you may be entitled to",
    }
  end

  before do
    stub_content_store_has_item("/business-coronavirus-support-finder")
  end

  scenario "Answers all questions" do
    visit "/business-coronavirus-support-finder"
    expect(page).to have_selector("h1", text: headings[:flow_title])

    click_govuk_start_button
    expect(page).to have_selector("h1", text: headings[:business_based])

    choose "England"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:business_size])

    choose "0 to 249 employees"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:annual_turnover])

    choose "My business is a start-up and is pre-revenue"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:paye_scheme])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:self_employed])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:non_domestic_property])

    choose "Under £51,000"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:sectors])

    check "Nurseries"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:closed_by_restrictions])

    check "No"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:flow_title])
    expect(page).to have_selector("h2", text: headings[:results])
  end

  scenario "Skip last question if business type nightclubs" do
    visit "/business-coronavirus-support-finder"
    expect(page).to have_selector("h1", text: headings[:flow_title])

    click_govuk_start_button
    expect(page).to have_selector("h1", text: headings[:business_based])

    choose "England"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:business_size])

    choose "0 to 249 employees"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:annual_turnover])

    choose "My business is a start-up and is pre-revenue"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:paye_scheme])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:self_employed])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:non_domestic_property])

    choose "Under £51,000"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:sectors])

    check "Nightclub, dancehall, or adult entertainment venue"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:flow_title])
    expect(page).to have_selector("h2", text: headings[:results])
  end
end
