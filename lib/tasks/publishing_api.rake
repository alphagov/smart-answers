namespace :publishing_api do
  desc "Publish smart answers to the content-store"
  task publish: [:environment] do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemPublisher.new.publish(flow_presenters)
  end

  desc "Unpublish a smart answer from content-store"
  task :unpublish, [:content_id] => :environment do |_, args|
    raise "Missing content-id parameter" unless args.content_id

    ContentItemPublisher.new.unpublish(args.content_id)
  end

  desc "Create redirect for a smart answer's paths on the content-store"
  task :redirect_smart_answer, [:path, :destination] => :environment do |_, args|
    raise "Missing path parameter" unless args.path
    raise "Missing destination parameter" unless args.destination

    ContentItemPublisher.new.redirect_smart_answer(args.path, args.destination)
  end
end
