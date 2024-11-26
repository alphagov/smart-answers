require "test_helper"

class GovukChatPromoHelperTest < ActionView::TestCase
  context "#show_govuk_chat_promo?" do
    should "return false when configuration disabled" do
      assert_not show_govuk_chat_promo?(GovukChatPromoHelper::GOVUK_CHAT_PROMO_BASE_URLS.first)
    end

    should "return false when base_url is not in allow list" do
      ENV["GOVUK_CHAT_PROMO_ENABLED"] = "true"

      assert_not show_govuk_chat_promo?("/non-matching-path")
    ensure
      ENV["GOVUK_CHAT_PROMO_ENABLED"] = nil
    end

    should "return true when base_url is in allow list" do
      ENV["GOVUK_CHAT_PROMO_ENABLED"] = "true"

      assert show_govuk_chat_promo?(GovukChatPromoHelper::GOVUK_CHAT_PROMO_BASE_URLS.first)
    ensure
      ENV["GOVUK_CHAT_PROMO_ENABLED"] = nil
    end
  end
end
