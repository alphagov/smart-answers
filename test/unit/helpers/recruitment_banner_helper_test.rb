require "test_helper"

class RecruitmentBannerHelperTest < ActionView::TestCase
  include RecruitmentBannerHelper

  def setup
    @recruitment_banners_data = YAML.load_file(Rails.root.join("test/fixtures/recruitment_banners.yml"))
  end

  def request
    OpenStruct.new(path: "/")
  end

  def recruitment_banners
    @recruitment_banners_data["banners"]
  end

  test "recruitment_banner returns banners that include the current url" do
    actual_banners = recruitment_banner

    expected_banners =
      {
        "name" => "Banner 1",
        "suggestion_text" => "Help improve GOV.UK",
        "suggestion_link_text" => "Take part in user research",
        "survey_url" => "https://google.com",
        "page_paths" => ["/"],
      }
    assert_equal expected_banners, actual_banners
  end

  test "recruitment_banners yaml structure is valid" do
    @recruitment_banners_data = YAML.load_file(Rails.root.join("lib/data/recruitment_banners.yml"))

    if @recruitment_banners_data["banners"].present?
      recruitment_banners.each do |banner|
        assert banner.key?("suggestion_text"), "Banner is missing 'suggestion_text' key"
        assert_not banner["suggestion_text"].blank?, "'suggestion_text' key should not be blank"

        assert banner.key?("suggestion_link_text"), "Banner is missing 'suggestion_link_text' key"
        assert_not banner["suggestion_link_text"].blank?, "'suggestion_link_text' key should not be blank"

        assert banner.key?("survey_url"), "Banner is missing 'survey_url' key"
        assert_not banner["survey_url"].blank?, "'survey_url' key should not be blank"

        assert banner.key?("page_paths"), "Banner is missing 'page_paths' key"
        assert_not banner["page_paths"].blank?, "'page_paths' key should not be blank"
      end
    end
  end
end
