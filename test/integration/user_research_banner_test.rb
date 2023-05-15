require_relative "../integration_test_helper"

class UserResearchBannerTest < ActionDispatch::IntegrationTest
  context "cost of living research banner" do
    context "check benefits financial support" do
      setup do
        stub_content_store_has_item("/check-benefits-financial-support")
      end

      should "display Recruitment Banner on the landing page" do
        visit "/check-benefits-financial-support"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://gdsuserresearch.optimalworkshop.com/treejack/f49b8c01521bf45bd0a519fe02f5f913")
      end

      should "not display Recruitment Banner on non-landing pages of the specific smart answer" do
        visit "/check-benefits-financial-support/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://gdsuserresearch.optimalworkshop.com/treejack/f49b8c01521bf45bd0a519fe02f5f913")
      end

      should "not display Recruitment Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://gdsuserresearch.optimalworkshop.com/treejack/f49b8c01521bf45bd0a519fe02f5f913")
      end
    end
  end
end
