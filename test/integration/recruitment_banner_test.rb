require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  context "brand user research banner" do
    context "check state pension age" do
      setup do
        stub_content_store_has_item("/check-benefits-financial-support")
      end

      should "display Brand User Research Banner on the landing page" do
        visit "/check-benefits-financial-support"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://forms.office.com/e/CkfCRwdLQj")
      end

      should "not display Brand User Research Banner on non-landing pages of the specific smart answer" do
        visit "/check-benefits-financial-support/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://forms.office.com/e/CkfCRwdLQj")
      end

      should "not display Brand User Research Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://forms.office.com/e/CkfCRwdLQj")
      end

      should "display on outcome page" do
        visit "/check-benefits-financial-support/y/england/no/yes/sixteen_or_more_per_week/no/no/no/no/over_16000"

        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://forms.office.com/e/CkfCRwdLQj")
      end
    end
  end
end
