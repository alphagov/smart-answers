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

  def redirect_smart_answer(path, destination)
    if path.present? && destination.present?
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

      if response.code == 200
        Services.publishing_api.publish(content_id, :major)
        Services.router_api.add_redirect_route(
          path,
          :prefix,
          destination,
          :permanent,
          segments_mode: :ignore
        )
      else
        raise "This content item has not been created"
      end
    else
      raise "The destination or path isn't defined"
    end
  end
end
