require_relative 'engine_test_helper'

class ReportAProblemTest < EngineIntegrationTest
  with_and_without_javascript do
    context "smart-answer" do
      setup do
        visit "/bridge-of-death"
      end

      context "start page" do
        should "show report-a-problem" do
          assert page.has_selector?('.report-a-problem-toggle a'), "Report a problem link not visible"
        end

        should "have current url in report-a-problem" do
          assert_match /\/bridge-of-death$/, page.find('#url', visible: false).value
        end
      end

      context "question" do
        setup do
          click_on "Start now"
          fill_in "Name:", with: "Lancelot"
        end

        should "show report-a-problem" do
          assert page.has_selector?('.report-a-problem-toggle a'), "Report a problem link not visible"
        end
      end

      context "question" do
        setup do
          click_on "Start now"
          fill_in "Name:", with: "Lancelot"
          click_on "Next step"
        end

        should "show report-a-problem" do
          assert page.has_selector?('.report-a-problem-toggle a'), "Report a problem link not visible"
        end
      end

      context "outcome" do
        setup do
          click_on "Start now"
          fill_in "Name:", with: "Lancelot"
          click_on "Next step"
          choose "To seek the Holy Grail"
          click_on "Next step"
          choose "Blue"
          click_on "Next step"
        end

        should "show report-a-problem" do
          assert page.has_selector?('.report-a-problem-toggle a'), "Report a problem link not visible"
        end

        should "have current url in report-a-problem" do
          assert page.find('input[value$="/bridge-of-death/y/Lancelot/to_seek_the_holy_grail/blue"]', visible: false)
        end
      end
    end
  end
end
