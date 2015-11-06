class ContentItemPublisher
  def publish(flow_presenters)
    flow_presenters.each do |smart_answer|
      content_item = FlowContentItem.new(smart_answer)
      Services.publishing_api.put_content(content_item.content_id, content_item.payload)
      Services.publishing_api.publish(content_item.content_id, 'minor')
    end
  end
end
