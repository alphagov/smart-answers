namespace :publishing_api do
  desc "Sync all smart answers with the Publishing API"
  task sync_all: [:environment] do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemSyncer.new.sync(flow_presenters)
  end

  desc "Sync a single smart answer with the Publishing API"
  task :sync, %i[slug] => [:environment] do |_, args|
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    ContentItemSyncer.new.sync(
      flow_presenters.select do |presenter|
        presenter.slug == args[:slug]
      end,
    )
  end
end
