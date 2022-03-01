class TravelAdviceHeaderCheckRetriever
  def self.fetch(country_slug)
    Rails.cache.fetch(country_slug, expires_in: 4.hours) do
      TravelAdviceHeaderChecker.new(country_slug).has_content_headers?
    end
  end
end
