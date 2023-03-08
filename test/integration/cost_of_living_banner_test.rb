require_relative "../integration_test_helper"

class CostOfLivingBannerTest < ActionDispatch::IntegrationTest
  context "cost of living survey banner" do
    setup do
      stub_content_store_has_item("/check-benefits-financial-support")
    end

    should "display cost of living survey banner on the landing page" do
      visit "/check-benefits-financial-support"

      assert page.has_css?(".gem-c-intervention")
      assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://s.userzoom.com/m/MSBDMTQ3MVM0NCAg")
    end

    should "not display cost of living survey banner on non-landing pages of the specific smart answer" do
      visit "/check-benefits-financial-support/y"

      assert_not page.has_css?(".gem-c-intervention")
      assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://s.userzoom.com/m/MSBDMTQ3MVM0NCAg")
    end

    should "not display cost of living survey banner unless survey URL is specified for the base path" do
      visit "/bridge-of-death"

      assert_not page.has_css?(".gem-c-intervention")
    end
  end
end
