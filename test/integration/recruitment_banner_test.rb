require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  setup do
    stub_content_store_has_item("/maternity-paternity-pay-leave")
    stub_content_store_has_item("/bridge-of-death")
    setup_fixture_flows
  end

  teardown { teardown_fixture_flows }

  should "display Recruitment Banner on the landing page of the specific smart answer" do
    visit "/maternity-paternity-pay-leave"

    assert page.has_css?(".gem-c-intervention")
    assert page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/834dm2s6")
  end

  should "not display Recruitment Banner on non-landing pages of the specific smart answer" do
    visit "/maternity-paternity-pay-leave/y"

    assert_not page.has_css?(".gem-c-intervention")
    assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/834dm2s6")
  end

  should "not display Recruitment Banner unless survey URL is specified for the base path" do
    visit "/bridge-of-death"

    assert_not page.has_css?(".gem-c-intervention")
    assert_not page.has_link?("Take part in user research (opens in a new tab)", href: "https://GDSUserResearch.optimalworkshop.com/treejack/834dm2s6")
  end
end
