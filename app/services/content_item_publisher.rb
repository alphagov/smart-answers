class ContentItemPublisher
  def sync(flow_presenters)
    flow_presenters.each do |smart_answer|
      start_page_content_item = StartPageContentItem.new(smart_answer)
      Services.publishing_api.put_content(start_page_content_item.content_id, start_page_content_item.payload)
      Services.publishing_api.publish(start_page_content_item.content_id) if smart_answer.publish?

      flow_content_item = FlowContentItem.new(smart_answer)
      Services.publishing_api.put_content(flow_content_item.content_id, flow_content_item.payload)
      Services.publishing_api.publish(flow_content_item.content_id) if smart_answer.publish?
    end
  end

  def unpublish(content_id)
    raise "Content id has not been supplied" if content_id.blank?

    Services.publishing_api.unpublish(
      content_id,
      type: "gone",
      unpublished_at: Time.zone.now,
    )
  end

  def unpublish_with_redirect(content_id, path, destination)
    raise "Content id has not been supplied" if content_id.blank?
    raise "Path has not been supplied" if path.blank?
    raise "Destination has not been supplied" if destination.blank?

    Services.publishing_api.unpublish(
      content_id,
      type: "redirect",
      redirects: [
        {
          path: path,
          type: :prefix,
          destination: destination,
          segments_mode: :ignore,
        },
      ],
    )
  end

  def unpublish_with_vanish(content_id)
    raise "Content id has not been supplied" if content_id.blank?

    Services.publishing_api.unpublish(content_id, type: "vanish")
  end

  def reserve_path_for_publishing_app(base_path, publishing_app)
    raise "The destination or path isn't supplied" unless base_path.present? && publishing_app.present?

    Services.publishing_api.put_json(
      reserve_path_url(base_path),
      publishing_app: publishing_app,
      override_existing: true,
    )
  end

private

  def reserve_path_url(base_path)
    "#{Plek.new.find('publishing-api')}/paths/#{base_path}"
  end

end
