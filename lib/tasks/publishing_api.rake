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
end
