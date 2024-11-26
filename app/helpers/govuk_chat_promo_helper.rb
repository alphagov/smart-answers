module GovukChatPromoHelper
  GOVUK_CHAT_PROMO_BASE_URLS = %w[
    /am-i-getting-minimum-wage
  ].freeze

  def show_govuk_chat_promo?(base_url)
    ENV["GOVUK_CHAT_PROMO_ENABLED"] == "true" && GOVUK_CHAT_PROMO_BASE_URLS.include?(base_url)
  end
end
