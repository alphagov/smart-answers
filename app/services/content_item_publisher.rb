class ContentItemPublisher
  def publish(flow_presenters)
    flow_presenters.each do |smart_answer|
      start_page_content_item = StartPageContentItem.new(smart_answer)
      Services.publishing_api.put_content(start_page_content_item.content_id, start_page_content_item.payload)
      Services.publishing_api.publish(start_page_content_item.content_id)

      flow_content_item = FlowContentItem.new(smart_answer)
      Services.publishing_api.put_content(flow_content_item.content_id, flow_content_item.payload)
      Services.publishing_api.publish(flow_content_item.content_id)
    end
  end

  def unpublish(content_id)
    raise "Content id has not been supplied" unless content_id.present?

    Services.publishing_api.unpublish(
      content_id,
      type: "gone",
      unpublished_at: Time.now,
    )
  end

  def unpublish_with_redirect(content_id, path, destination)
    raise "Content id has not been supplied" unless content_id.present?
    raise "Path has not been supplied" unless path.present?
    raise "Destination has not been supplied" unless destination.present?

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
    raise "Content id has not been supplied" unless content_id.present?

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

  def publish_transaction(base_path, publishing_app:, title:, content:, link:)
    raise "The base path isn't supplied" unless base_path.present?
    raise "The publishing_app isn't supplied" unless publishing_app.present?
    raise "The title isn't supplied" unless title.present?
    raise "The content isn't supplied" unless content.present?
    raise "The link isn't supplied" unless link.present?

    publish_transaction_via_publishing_api(
      base_path,
      publishing_app: publishing_app,
      title: title,
      content: content,
      link: link,
    )
  end

  def publish_answer(base_path, publishing_app:, title:, content:)
    raise "The base path isn't supplied" unless base_path.present?
    raise "The publishing_app isn't supplied" unless publishing_app.present?
    raise "The title isn't supplied" unless title.present?
    raise "The content isn't supplied" unless content.present?

    publish_answer_via_publishing_api(
      base_path,
      publishing_app: publishing_app,
      title: title,
      content: content,
    )
  end

private

  def reserve_path_url(base_path)
    "#{Plek.new.find('publishing-api')}/paths/#{base_path}"
  end

  def publish_answer_via_publishing_api(base_path, publishing_app:, title:, content:)
    payload = {
      base_path: base_path,
      title: title,
      document_type: :answer,
      schema_name: :answer,
      publishing_app: publishing_app,
      rendering_app: :frontend,
      update_type: :major,
      locale: :en,
      details: {
        body: [
          {
            content: content,
            content_type: "text/govspeak",
          },
        ],
      },
      routes: [
        {
          type: :exact,
          path: base_path,
        },
      ],
    }

    create_and_publish_via_publishing_api(payload)
  end

  def publish_transaction_via_publishing_api(base_path, publishing_app:, title:, content:, link:)
    payload = {
      base_path: base_path,
      title: title,
      update_type: :major,
      document_type: :transaction,
      publishing_app: publishing_app,
      rendering_app: :frontend,
      locale: :en,
      details: {
        introductory_paragraph: [
          {
            content: content,
            content_type: "text/govspeak",
          },
        ],
        transaction_start_link: link,
      },
      routes: [
        {
          type: :exact,
          path: base_path,
        },
      ],
      schema_name: :transaction,
    }

    create_and_publish_via_publishing_api(payload)
  end

  def create_and_publish_via_publishing_api(payload)
    content_id = SecureRandom.uuid
    response = Services.publishing_api.put_content(content_id, payload)
    raise "This content item has not been created" unless response.code == 200

    Services.publishing_api.publish(content_id)
  end
end
