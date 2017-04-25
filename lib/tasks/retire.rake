namespace :retire do
  desc "Retire an identified smart answer"
  task :smart_answer, [:content_id, :base_path, :destination] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id.present?
    raise "Missing base_path parameter" unless args.base_path.present?
    raise "Missing destination parameter" unless args.destination.present?

    content_item_publisher = ContentItemPublisher.new

    content_item_publisher.unpublish(args.content_id)
    content_item_publisher.redirect_smart_answer(args.base_path, args.destination)
    content_item_publisher.remove_smart_answer_from_search(args.base_path)
  end

  desc "Unpublish a smart answer from publishing-api"
  task :unpublish, [:content_id] => :environment do |_, args|
    raise "Missing content-id parameter" unless args.content_id

    ContentItemPublisher.new.unpublish(args.content_id)
  end

  desc "Create redirect for a smart answer's paths on the publishing-api"
  task :redirect_smart_answer, [:path, :destination] => :environment do |_, args|
    raise "Missing path parameter" unless args.path
    raise "Missing destination parameter" unless args.destination

    ContentItemPublisher.new.redirect_smart_answer(args.path, args.destination)
  end

  desc "Remove smart answer from search"
  task :remove_smart_answer_from_search, [:base_path] => :environment do |_, args|
    raise "Missing base-path parameter" unless args.base_path

    ContentItemPublisher.new.remove_smart_answer_from_search(args.base_path)
  end

  desc "Change publishing application"
  task :change_owning_application, [:base_path, :publishing_app] => :environment do |_, args|
    raise "Missing base-path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app

    ContentItemPublisher.new.reserve_path_for_publishing_app(args.base_path, args.publishing_app)
  end

  desc "Publish transaction via publishing api"
  task :publish_transaction, [:base_path, :publishing_app, :title, :content, :link] => :environment do |_, args|
    raise "Missing base path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app
    raise "Missing title parameter" unless args.title
    raise "Missing content parameter" unless args.content
    raise "Missing link parameter" unless args.link

    ContentItemPublisher.new.reserve_path_for_publishing_app(
      args.base_path,
      args.publishing_app
    )

    ContentItemPublisher.new.publish_transaction(
      args.base_path,
      publishing_app: args.publishing_app,
      title: args.title,
      content: args.content,
      link: args.link
    )
  end
end
