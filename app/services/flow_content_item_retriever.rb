class FlowContentItemRetriever
  def self.fetch(slug)
    base_path = FlowContentItem.base_path_for_slug(slug)
    Services.content_store.content_item(base_path)
      .to_hash.with_indifferent_access
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
    {}
  end
end
