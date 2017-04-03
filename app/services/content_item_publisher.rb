class ContentItemPublisher
  def publish(flow_presenters)
    flow_presenters.each do |smart_answer|
      content_item = FlowContentItem.new(smart_answer)
      Services.publishing_api.put_content(content_item.content_id, content_item.payload)
      Services.publishing_api.publish(content_item.content_id, 'minor')
    end
  end

  def unpublish(content_id)
    if content_id.present?
      Services.publishing_api.unpublish(
        content_id,
        type: "gone",
        unpublished_at: Time.now
      )
    else
      raise "Content id has not been supplied"
    end
  end
end
