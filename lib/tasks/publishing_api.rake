namespace :publishing_api do
  desc "Publish smart answers to the content-store"
  task publish_all: [:environment] do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemPublisher.new.publish(flow_presenters)
  end

  task :publish_single, %i[slug] => [:environment] do |_, args|
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemPublisher.new.publish(
      flow_presenters.select do |presenter|
        presenter.slug == args[:slug]
      end,
    )
  end
end
