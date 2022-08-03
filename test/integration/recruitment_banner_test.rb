require_relative "../integration_test_helper"

class RecruitmentBannerTest < ActionDispatch::IntegrationTest
  def tree_test_banner
    {
      URL: "https://GDSUserResearch.optimalworkshop.com/treejack/834dm2s6",
      path: "/maternity-paternity-pay-leave",
    }
  end

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "Tree test recruitment banners" do
    setup do
      stub_content_store_has_item(tree_test_banner[:path])
      stub_content_store_has_item("/bridge-of-death")
    end

    should "display Recruitment Banner on the landing page of the specific smart answer" do
      visit tree_test_banner[:path]
      assert page.has_css?(".gem-c-intervention")
      assert page.has_link?("Take part in user research (opens in a new tab)", href: tree_test_banner[:URL])
    end

    should "not display Recruitment Banner on non-landing pages of the specific smart answer" do
      visit "#{tree_test_banner[:path]}/y"

      assert_not page.has_css?(".gem-c-intervention")
      assert_not page.has_link?("Take part in user research (opens in a new tab)", href: tree_test_banner[:URL])
    end

    should "not display Recruitment Banner unless survey URL is specified for the base path" do
      visit "/bridge-of-death"

      assert_not page.has_css?(".gem-c-intervention")
      assert_not page.has_link?("Take part in user research (opens in a new tab)", href: tree_test_banner[:URL])
    end
  end
end
