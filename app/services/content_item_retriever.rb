class ContentItemRetriever
  def self.fetch(slug)
    Services.content_store.content_item("/#{slug}")
      .to_hash.with_indifferent_access

  rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
    {}
  end

  def self.without_links_organisations(slug)
    # The GOV.UK analytics component[1] automatically sets `govuk:analytics:organisations`
    # if there's a `organisations` key in the links. This will be sent to Google
    # Analytics At the moment we want to avoid setting this because it will flood
    # the analytics reports with (unexpected) data. We are currently working on
    # a solution to this conundrum[2].
    #
    # [1] http://govuk-component-guide.herokuapp.com/components/analytics_meta_tags
    # [2] https://trello.com/c/DkR63grd
    content_item = fetch(slug)
    content_item[:links].delete(:organisations) if valid_links_organisations?(content_item)

    content_item
  end

  def self.valid_links_organisations?(content_item)
    content_item.has_key?(:links) &&
      content_item[:links].is_a?(Hash) &&
      content_item[:links].has_key?(:organisations)
  end

  private_class_method :valid_links_organisations?
end
