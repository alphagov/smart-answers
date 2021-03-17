RSpec.feature "Flow navigation", type: :feature do
  before do
    SmartAnswer::FlowRegistry.reset_instance(
      preload_flows: false,
      smart_answer_load_path: Rails.root.join("spec/fixtures/flows"),
    )
    stub_content_store_has_item("/test")
  end

  scenario "User completes a flow" do
    visit "/test/s"

    choose "Response 1"
    click_button "Continue"

    fill_in "response", with: "Response"
    click_button "Continue"

    expect(page).to have_text("Results title")
  end

  scenario "User changes their answer to previous question" do
    visit "/test/s"

    choose "Response 1"
    click_button "Continue"

    click_on "Change"

    expect(page).to have_text("Question 1 title")
  end

  scenario "User start the flow again" do
    visit "/test/s"

    choose "Response 1"
    click_button "Continue"

    fill_in "response", with: "Response"
    click_button "Continue"

    click_on "Start again"

    expect(page).to have_text("This is a test flow")
  end
end
