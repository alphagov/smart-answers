require_relative "../integration_test_helper"

class StartPageTest < ActionDispatch::IntegrationTest
  context "start page" do
    RegisterableSmartAnswers.new.flow_presenters.each do |flow_presenter|
      slug = flow_presenter.slug
      next if slug == "part-year-profit-tax-credits/y"
      context "when the smart answer is `#{slug}`" do
        setup do
          @view = mock("view")
          @view.stubs(:smart_answer_path).returns("/#{slug}/y")
        end

        should "have button text and href belonging to this smart answer" do
          start_button = SmartAnswer::StartButton.new(slug, @view)
          Services.content_store.stubs(:content_item)
            .with("/#{slug}")
            .returns({})

          visit "/#{slug}"

          assert_current_url "/#{slug}"
          within ".intro" do
            assert page.has_link?(
              start_button.text,
              href: start_button.href
            )
          end
        end
      end
    end
  end
end
