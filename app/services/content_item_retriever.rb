class ContentItemRetriever
  def self.fetch(slug)
    item_hash = Rails.cache.fetch("ContentItemRetriever/#{slug}", expires_in: 30.minutes) do
      res = GdsApi.content_store.content_item("/#{slug}")
      h = res.to_h
      h["cache_control"] = res.cache_control
      h
    end

    item_hash.with_indifferent_access
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    {}
  end
end
