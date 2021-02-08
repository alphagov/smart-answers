require "rails_helper"

RSpec.feature "FindCoronavirusSupportFlow", type: :feature do
  def start_flow_to_need_help_with
    visit "/find-coronavirus-support"
    expect(page).to have_selector("h1", text: headings[:flow_title])

    click_link "Start now"
    expect(page).to have_selector("h1", text: headings[:need_help_with])
  end

  def continue_to_results
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:nation])

    choose "England"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:results])
  end

  let(:headings) do
    {
      flow_title: "Find out what support you can get if you’re affected by coronavirus",
      need_help_with: "What do you need help with because of coronavirus?",
      feel_unsafe: "Do you feel unsafe where you live?",
      afford_rent_mortgage_bills: "Are you finding it hard to pay your rent, mortgage or bills?",
      afford_food: "Are you finding it hard to afford food?",
      get_food: "Are you able to get food or medicine?",
      self_employed: "Are you self-employed, a freelancer, or a sole trader?",
      have_you_been_made_unemployed: "Have you been made redundant or told to stop working?",
      worried_about_work: "Are you worried about going in to work?",
      worried_about_self_isolating: "Are you self-isolating?",
      have_somewhere_to_live: "Do you have somewhere to live?",
      have_you_been_evicted: "Have you been evicted?",
      mental_health_worries: "Are you worried about your mental health, or another adult or child’s mental health?",
      nation: "Where do you want to find information about?",
      results: "Information based on your answers",
    }
  end

  let(:result_subheadings) do
    {
      feeling_unsafe: "Feeling unsafe",
      paying_bills: "Paying your rent, mortgage, or bills",
      getting_food: "Getting food or medicine",
      being_unemployed: "Being made redundant or unemployed, or not having any work",
      going_to_work: "Being worried about working",
      self_isolating: "Self-isolating",
      somewhere_to_live: "Having somewhere to live",
      mental_health: "Mental health and wellbeing",
    }
  end

  let(:need_help_with) do
    {
      feeling_unsafe: "Feeling unsafe where you live, or what to do if you’re worried about the safety of another adult or child",
      paying_bills: "Paying your rent, mortgage, or bills",
      getting_food: "Getting food or medicine",
      being_unemployed: "Being made redundant or unemployed, or not having any work if you're self-employed",
      going_to_work: "Being worried about working",
      self_isolating: "Self-isolating",
      somewhere_to_live: "Having somewhere to live",
      mental_health: "Mental health and wellbeing, including information for children",
      none: "None of these",
    }
  end

  before do
    stub_content_store_has_item("/find-coronavirus-support")
  end

  scenario "feeling unsafe" do
    start_flow_to_need_help_with

    check need_help_with[:feeling_unsafe]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:feel_unsafe])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:feeling_unsafe])
  end

  scenario "paying bills" do
    start_flow_to_need_help_with

    check need_help_with[:paying_bills]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:afford_rent_mortgage_bills])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:paying_bills])
  end

  scenario "getting food" do
    start_flow_to_need_help_with

    check need_help_with[:getting_food]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:afford_food])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:get_food])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:getting_food])
  end

  scenario "being unemployed" do
    start_flow_to_need_help_with

    check need_help_with[:being_unemployed]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:self_employed])

    choose "No"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:have_you_been_made_unemployed])

    choose "Yes, I’ve been made redundant or I’m out of work, or might be soon"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:being_unemployed])
  end

  scenario "being unemployed - self-employed" do
    start_flow_to_need_help_with

    check need_help_with[:being_unemployed]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:self_employed])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:being_unemployed])
  end

  scenario "going to work" do
    start_flow_to_need_help_with

    check need_help_with[:going_to_work]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:worried_about_work])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:going_to_work])
  end

  scenario "self isolating" do
    start_flow_to_need_help_with

    check need_help_with[:self_isolating]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:worried_about_self_isolating])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:self_isolating])
  end

  scenario "somewhere to live" do
    start_flow_to_need_help_with

    check need_help_with[:somewhere_to_live]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:have_somewhere_to_live])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:have_you_been_evicted])

    choose "Yes"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:somewhere_to_live])
  end

  scenario "mental health" do
    start_flow_to_need_help_with

    check need_help_with[:mental_health]
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:mental_health_worries])

    choose "Yes, I am"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:mental_health])
  end

  scenario "None of these" do
    start_flow_to_need_help_with
    check need_help_with[:none]
    continue_to_results
    expect(page).to have_text("Based on your answers, there’s no specific information for you in this service at the moment")
  end

  scenario "all the options" do
    start_flow_to_need_help_with

    check need_help_with[:mental_health]
    check need_help_with[:somewhere_to_live]
    check need_help_with[:going_to_work]
    check need_help_with[:self_isolating]
    check need_help_with[:being_unemployed]
    check need_help_with[:getting_food]
    check need_help_with[:paying_bills]
    check need_help_with[:feeling_unsafe]

    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:feel_unsafe])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:afford_rent_mortgage_bills])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:afford_food])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:get_food])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:self_employed])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:worried_about_work])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:worried_about_self_isolating])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:have_somewhere_to_live])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:have_you_been_evicted])

    choose "Yes"
    click_button "Continue"
    expect(page).to have_selector("h1", text: headings[:mental_health_worries])

    choose "Yes, I am"
    continue_to_results
    expect(page).to have_selector("h2", text: result_subheadings[:mental_health])
    expect(page).to have_selector("h2", text: result_subheadings[:somewhere_to_live])
    expect(page).to have_selector("h2", text: result_subheadings[:going_to_work])
    expect(page).to have_selector("h2", text: result_subheadings[:self_isolating])
    expect(page).to have_selector("h2", text: result_subheadings[:being_unemployed])
    expect(page).to have_selector("h2", text: result_subheadings[:getting_food])
    expect(page).to have_selector("h2", text: result_subheadings[:paying_bills])
    expect(page).to have_selector("h2", text: result_subheadings[:feeling_unsafe])
  end
end
