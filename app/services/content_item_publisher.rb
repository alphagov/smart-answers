class ContentItemPublisher
  def publish(flow_presenters)
    flow_presenters.each do |smart_answer|
      content_item = FlowContentItem.new(smart_answer)
      Services.publishing_api.put_content(content_item.content_id, content_item.payload)
      Services.publishing_api.publish(content_item.content_id, 'minor')
    end
  end

  def unpublish(content_id)
    raise "Content id has not been supplied" unless content_id.present?

    Services.publishing_api.unpublish(
      content_id,
      type: "gone",
      unpublished_at: Time.now
    )
  end

  def redirect_smart_answer(path, destination)
    raise "The destination or path isn't defined" unless path.present? && destination.present?

    add_redirect_to_publishing_api(path, destination)
    update_segment_mode_in_router_api(path, destination)
  end

private

  def add_redirect_to_publishing_api(path, destination)
    content_id = SecureRandom.uuid
    create_params = {
      base_path: path,
      document_type: :redirect,
      publishing_app: :smartanswers,
      schema_name: :redirect,
      redirects: [
        { path: path, type: :prefix, destination: destination }
      ]
    }

    response = Services.publishing_api.put_content(content_id, create_params)
    raise "This content item has not been created" unless response.code == 200
    Services.publishing_api.publish(content_id, :major)
  end

  def update_segment_mode_in_router_api(path, destination)
    Services.router_api.add_redirect_route(
      path,
      :prefix,
      destination,
      :permanent,
      segments_mode: :ignore
    )
  end
end
