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
  task :redirect_smart_answer, [:path, :destination] => :environment do |_,args|
    raise "Missing path parameter" unless args.path
    raise "Missing destination parameter" unless args.destination

    ContentItemPublisher.new.redirect_smart_answer(args.path, args.destination)
  end
end
