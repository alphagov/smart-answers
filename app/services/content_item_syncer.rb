class ContentItemSyncer
  def sync(flow_presenters)
    flow_presenters.each do |smart_answer|
      start_page_content_item = StartPageContentItem.new(smart_answer)
      GdsApi.publishing_api.put_content(start_page_content_item.content_id, start_page_content_item.payload)
      GdsApi.publishing_api.publish(start_page_content_item.content_id) if smart_answer.publish?
    end
  end
end
