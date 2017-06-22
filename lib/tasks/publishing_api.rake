namespace :publishing_api do
  desc "Publish smart answers to the content-store"
  task publish: [:environment] do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemPublisher.new.publish(flow_presenters)
  end

  desc "Publish transaction start page via publishing api"
  task :publish_start_page_as_transaction, [:content_id, :base_path, :publishing_app, :title, :content, :link] => :environment do |_, args|
    raise "Missing content id parameter" unless args.content_id
    raise "Missing base path parameter" unless args.base_path
    raise "Missing publishing_app parameter" unless args.publishing_app
    raise "Missing title parameter" unless args.title
    raise "Missing content parameter" unless args.content
    raise "Missing link parameter" unless args.link

    ContentItemPublisher.new.reserve_path_for_publishing_app(
      args.base_path,
      args.publishing_app
    )

    ContentItemPublisher.new.publish_transaction_start_page(
      args.content_id,
      args.base_path,
      publishing_app: args.publishing_app,
      title: args.title,
      content: args.content,
      link: args.link
    )
  end
end
