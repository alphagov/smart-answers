require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  context "brand user research banner" do
    context "check state pension age" do
      setup do
        stub_content_store_has_item("/state-pension-age")
      end

      should "display Brand User Research Banner on the landing page" do
        visit "/state-pension-age"
        assert page.has_css?(".gem-c-intervention")
        assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/5G06FO/")
      end

      should "not display Brand User Research Banner on non-landing pages of the specific smart answer" do
        visit "/state-pension-age/y"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/5G06FO/")
      end

      should "not display Brand User Research Banner unless survey URL is specified for the base path" do
        visit "/bridge-of-death"

        assert_not page.has_css?(".gem-c-intervention")
        assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://surveys.publishing.service.gov.uk/s/5G06FO/")
      end
    end
  end
end
