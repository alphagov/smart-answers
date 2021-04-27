class ContentItemSyncer
  def sync(flows)
    flows.each do |flow|
      content_item = ContentItemPresenter.new(flow)
      GdsApi.publishing_api.put_content(flow.content_id, content_item.payload)
      GdsApi.publishing_api.publish(flow.content_id) if flow.status == :published
    end
  end
end
