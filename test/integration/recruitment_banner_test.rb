require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  context "cost of living recruitment banner" do
    context "child benefit tax calculator" do
      setup do
        stub_content_store_has_item("/child-benefit-tax-calculator")
      end

      should "display Recruitment Banner on the landing page" do
        visit "/child-benefit-tax-calculator"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a")
      end

      should "not display Recruitment Banner on non-landing pages of the specific smart answer" do
        visit "/child-benefit-tax-calculator/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a")
      end

      should "not display Recruitment Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a")
      end
    end

    context "state pension age smart answer" do
      setup do
        stub_content_store_has_item("/state-pension-age")
      end

      should "display Recruitment Banner on the landing page" do
        visit "/state-pension-age"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a")
      end

      should "not display Recruitment Banner on non-landing pages of the specific smart answer" do
        visit "/state-pension-age/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/cbd7a696cbf57c683cbb2e95b4a36c8a")
      end
    end
  end
end
