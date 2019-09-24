namespace :retire do
  desc "Unpublish, redirect and remove from the search index an identified smart answer"
  task :unpublish_redirect_remove_from_search, %i[content_id base_path destination] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id.present?
    raise "Missing base_path parameter" unless args.base_path.present?
    raise "Missing destination parameter" unless args.destination.present?

    content_item_publisher = ContentItemPublisher.new

    content_item_publisher.unpublish_with_redirect(
      args.content_id, args.base_path, args.destination
    )
  end

  desc "Unpublish a smart answer from publishing-api"
  task :unpublish, [:content_id] => :environment do |_, args|
    raise "Missing content-id parameter" unless args.content_id

    ContentItemPublisher.new.unpublish(args.content_id)
  end

  desc "Unpublish a smart answer from publishing-api, with an unpublish type of vanish"
  task :unpublish_with_vanish, [:content_id] => :environment do |_, args|
    raise "Missing content-id parameter" unless args.content_id

    ContentItemPublisher.new.unpublish_with_vanish(args.content_id)
  end

  desc "Change publishing application"
  task :change_owning_application, %i[base_path publishing_app] => :environment do |_, args|
    raise "Missing base-path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app

    ContentItemPublisher.new.reserve_path_for_publishing_app(args.base_path, args.publishing_app)
  end

  desc "Publish transaction via publishing api"
  task :publish_transaction, %i[base_path publishing_app title content link] => :environment do |_, args|
    raise "Missing base path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app
    raise "Missing title parameter" unless args.title
    raise "Missing content parameter" unless args.content
    raise "Missing link parameter" unless args.link

    ContentItemPublisher.new.reserve_path_for_publishing_app(
      args.base_path,
      args.publishing_app,
    )

    ContentItemPublisher.new.publish_transaction(
      args.base_path,
      publishing_app: args.publishing_app,
      title: args.title,
      content: args.content,
      link: args.link,
    )
  end

  desc "Publish answer via publishing api"
  task :publish_answer, %i[base_path publishing_app title content] => :environment do |_, args|
    raise "Missing base path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app
    raise "Missing title parameter" unless args.title
    raise "Missing content parameter" unless args.content

    ContentItemPublisher.new.reserve_path_for_publishing_app(
      args.base_path,
      args.publishing_app,
    )

    ContentItemPublisher.new.publish_answer(
      args.base_path,
      publishing_app: args.publishing_app,
      title: args.title,
      content: args.content,
    )
  end
end
