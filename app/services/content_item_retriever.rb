class ContentItemRetriever
  def self.fetch(slug)
    item_hash = Rails.cache.fetch("ContentItemRetriever/#{slug}", expires_in: 30.minutes) do
      GdsApi.content_store.content_item("/#{slug}").to_hash
    end

    item_hash.with_indifferent_access
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
    {}
  end
end
