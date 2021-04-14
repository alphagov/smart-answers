RSpec.feature "Session based flow navigation", flow_dir: :fixture do
  scenario "User completes a flow" do
    visit "/session-based"
    click_on "Start now"

    choose "Response 1"
    click_button "Continue"

    fill_in "response", with: "Response"
    click_button "Continue"

    expect(page).to have_text("Results title")
  end

  scenario "User changes their answer to previous question" do
    visit "/session-based"
    click_on "Start now"

    choose "Response 1"
    click_button "Continue"

    click_on "Change"

    expect(page).to have_text("Question 1 title")
  end

  scenario "User start the flow again" do
    visit "/session-based"
    click_on "Start now"

    choose "Response 1"
    click_button "Continue"

    fill_in "response", with: "Response"
    click_button "Continue"

    click_on "Start again"

    expect(page).to have_text("This is a test flow")
  end
end
