class ContentItemPublisher
  def publish(flow_presenters)
    start_page_less_smart_answer = flow_presenters.select { |smart_answer| smart_answer.slug == "part-year-profit-tax-credits/y" }.first
    start_page_smart_answer = flow_presenters.select { |smart_answer| smart_answer.slug == "part-year-profit-tax-credits" }.first
    flow_presenters.each do |smart_answer|
      content_item = case smart_answer
                     when start_page_less_smart_answer
                       StartPageLessFlowContentItem.new(smart_answer)
                     when start_page_smart_answer
                       nil
                     else
                       FlowContentItem.new(smart_answer)
                     end
      if content_item
        Services.publishing_api.put_content(content_item.content_id, content_item.payload)
        Services.publishing_api.publish(content_item.content_id, 'minor')
      end
    end
    remove_start_page
    self.publish_transaction_start_page(
      "de6723a5-7256-4bfd-aad3-82b04b06b73e",
      "/part-year-profit-tax-credits",
      publishing_app: "publisher",
      title: "Calculate your part-year profits to finalise your tax credits",
      content: "You need to report your part-year profits to end your Tax Credits claim because of a claim to Universal Credit and you’re self-employed.\n\nYou’ll need to know the following to use this calculator:\n\n- your Tax Credits award end date (you can find this on your award review)\n- your accounting dates for your business\n- your accounting year profit for the tax year in which your tax credits award ends\n\nYou can use this calculator to complete box 2.4 of your award review.",
      link: "https://www.gov.uk/part-year-profit-tax-credits/y"
    )
  end

  def remove_start_page
    self.unpublish("de6723a5-7256-4bfd-aad3-82b04b06b73e")
    content_id_of_draft_to_discard = Services.publishing_api.lookup_content_ids(base_paths: "/part-year-profit-tax-credits").values.first
    Services.publishing_api.discard_draft(content_id_of_draft_to_discard) if content_id_of_draft_to_discard
  end

  def unpublish(content_id)
    raise "Content id has not been supplied" unless content_id.present?

    Services.publishing_api.unpublish(
      content_id,
      type: "gone",
      unpublished_at: Time.now
    )
  end

  def publish_redirect(path, destination)
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

  def publish_transaction_start_page(content_id, base_path, publishing_app:, title:, content:, link:)
    raise "The base path isn't supplied" unless base_path.present?
    raise "The publishing_app isn't supplied" unless publishing_app.present?
    raise "The title isn't supplied" unless title.present?
    raise "The content isn't supplied" unless content.present?
    raise "The link isn't supplied" unless link.present?

    publish_transaction_start_page_via_publishing_api(
      content_id,
      base_path,
      publishing_app: publishing_app,
      title: title,
      content: content,
      link: link
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
      content: content
    )
  end

private

  def reserve_path_url(base_path)
    "#{Plek.new.find('publishing-api')}/paths/#{base_path}"
  end

  def add_redirect_to_publishing_api(path, destination)
    payload = {
      base_path: path,
      document_type: :redirect,
      publishing_app: :smartanswers,
      schema_name: :redirect,
      redirects: [
        { path: path, type: :prefix, destination: destination, segments_mode: :ignore }
      ]
    }

    create_and_publish_via_publishing_api(payload)
  end

  def publish_answer_via_publishing_api(base_path, publishing_app:, title:, content:)
    payload = {
      base_path: base_path,
      title: title,
      document_type: :answer,
      schema_name: :answer,
      publishing_app: publishing_app,
      rendering_app: :frontend,
      locale: :en,
      details: {
        body: [
          {
            content: content,
            content_type: "text/govspeak"
          }
        ]
      },
      routes: [
        {
          type: :exact,
          path: base_path
        }
      ]
    }

    create_and_publish_via_publishing_api(payload)
  end

  def publish_transaction_via_publishing_api(base_path, publishing_app:, title:, content:, link:)
    payload = {
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

    create_and_publish_via_publishing_api(payload)
  end

  def publish_transaction_start_page_via_publishing_api(content_id, base_path, publishing_app:, title:, content:, link:)
    payload = {
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

    reserve_path_for_publishing_app(base_path, publishing_app)
    create_and_publish_via_publishing_api(payload, content_id)
  end

  def create_and_publish_via_publishing_api(payload, content_id = SecureRandom.uuid)
    response = Services.publishing_api.put_content(content_id, payload)
    raise "This content item has not been created" unless response.code == 200
    Services.publishing_api.publish(content_id, :major)
  end
end
