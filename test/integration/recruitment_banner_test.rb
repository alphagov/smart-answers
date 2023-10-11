require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  context "user research banner" do
    context "maternity paternity calculator" do
      setup do
        stub_content_store_has_item("/maternity-paternity-calculator")
      end

      should "display User Research Banner on the landing page" do
        visit "/maternity-paternity-calculator"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Sign up to take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/SNFVW1/")
      end

      should "not display User Research Banner on non-landing pages of the specific smart answer" do
        visit "/maternity-paternity-calculator/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Sign up to take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/SNFVW1/")
      end

      should "not display User Research Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Sign up to take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/SNFVW1/")
      end
    end

    context "check state pension age" do
      setup do
        stub_content_store_has_item("/state-pension-age")
      end

      should "display Benefits User Research Banner on the landing page" do
        visit "/state-pension-age"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://signup.take-part-in-research.service.gov.uk/home?utm_campaign=Content_History&utm_source=Hold_gov_to_account&utm_medium=gov.uk&t=GDS&id=16")
      end

      should "not display Benefits User Research Banner on non-landing pages of the specific smart answer" do
        visit "/state-pension-age/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://signup.take-part-in-research.service.gov.uk/home?utm_campaign=Content_History&utm_source=Hold_gov_to_account&utm_medium=gov.uk&t=GDS&id=16")
      end

      should "not display Benefits User Research Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://signup.take-part-in-research.service.gov.uk/home?utm_campaign=Content_History&utm_source=Hold_gov_to_account&utm_medium=gov.uk&t=GDS&id=16")
      end
    end
  end
end
