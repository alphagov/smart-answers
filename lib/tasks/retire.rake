namespace :retire do
  desc "Unpublish, redirect and remove from the search index an identified smart answer"
  task :unpublish_redirect_remove_from_search, %i[content_id base_path destination] => :environment do |_, args|
    raise "Missing content_id parameter" if args.content_id.blank?
    raise "Missing base_path parameter" if args.base_path.blank?
    raise "Missing destination parameter" if args.destination.blank?

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
end
