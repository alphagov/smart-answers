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
  end

  def remove_smart_answer_from_search(base_path)
    raise "The base_path isn't supplied" unless base_path.present?

    Services.rummager.delete_content(base_path)
  end

  def reserve_path_for_publishing_app(base_path, publishing_app)
    raise "The destination or path isn't supplied" unless base_path.present? && publishing_app.present?

    Services.publishing_api.put_json(
      reserve_path_url(base_path),
      publishing_app: publishing_app,
      override_existing: true
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
      link: link
    )
  end

private

  def reserve_path_url(base_path)
    "#{Plek.new.find('publishing-api')}/paths/#{base_path}"
  end

  def add_redirect_to_publishing_api(path, destination)
    content_id = SecureRandom.uuid
    create_params = {
      base_path: path,
      document_type: :redirect,
      publishing_app: :smartanswers,
      schema_name: :redirect,
      redirects: [
        { path: path, type: :prefix, destination: destination, segments_mode: :ignore }
      ]
    }

    response = Services.publishing_api.put_content(content_id, create_params)
    raise "This content item has not been created" unless response.code == 200
    Services.publishing_api.publish(content_id, :major)
  end

  def publish_transaction_via_publishing_api(base_path, publishing_app:, title:, content:, link:)
    content_id = SecureRandom.uuid
    create_params = {
      base_path: base_path,
      title: title,
      document_type: :transaction,
      publishing_app: publishing_app,
      rendering_app: :frontend,
      locale: :en,
      details: {
        introductory_paragraph: [
          {
            content: content,
            content_type: "text/govspeak"
          }
        ],
        transaction_start_link: link
      },
      routes: [
        {
          type: :exact,
          path: base_path
        }
      ],
      schema_name: :transaction
    }

    response = Services.publishing_api.put_content(content_id, create_params)
    raise "This content item has not been created" unless response.code == 200
    Services.publishing_api.publish(content_id, :major)
  end
end
