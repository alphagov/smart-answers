module TaxonomyNavigation
  def should_present_taxonomy_navigation_view?(content_item)
    content_is_tagged_to_world_wide_taxonomy?(content_item) ||
      (content_is_tagged_to_a_taxon?(content_item) &&
        !content_is_tagged_to_browse_pages?(content_item))
  end

private

  def content_is_tagged_to_world_wide_taxonomy?(content_item)
    content_item.dig("links", "taxons").to_a.any? do |item|
      item.fetch("base_path").starts_with?("/world")
    end
  end

  def content_is_tagged_to_a_taxon?(content_item)
    content_item.dig("links", "taxons").present?
  end

  def content_is_tagged_to_browse_pages?(content_item)
    content_item.dig("links", "mainstream_browse_pages").present?
  end
end
