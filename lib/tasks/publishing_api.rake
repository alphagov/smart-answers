namespace :publishing_api do
  desc "Publish smart answers to the content-store"
  task :publish => [:environment] do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemPublisher.new.publish(flow_presenters)
  end
end
