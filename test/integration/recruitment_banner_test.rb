require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  context "user research banner" do
    context "childcare costs for tax credits" do
      setup do
        stub_content_store_has_item("/childcare-costs-for-tax-credits")
      end

      should "display User Research Banner on the landing page" do
        visit "/childcare-costs-for-tax-credits"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/4J4QD4/")
      end

      should "not display User Research Banner on non-landing pages of the specific smart answer" do
        visit "/childcare-costs-for-tax-credits/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/4J4QD4/")
      end

      should "not display User Research Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/4J4QD4/")
      end
    end
  end
end
