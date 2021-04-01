class ContentItemSyncer
  def sync(flow_presenters)
    flow_presenters.each do |flow_presenter|
      content_item = ContentItem.new(flow_presenter)
      GdsApi.publishing_api.put_content(content_item.content_id, content_item.payload)
      GdsApi.publishing_api.publish(content_item.content_id) if flow_presenter.publish?
    end
  end
end
