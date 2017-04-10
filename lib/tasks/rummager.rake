namespace :rummager do
  desc "Indexes all smart answers in Rummager"
  task index: :environment do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    RummagerNotifier.new(flow_presenters).notify
  end

  desc "Remove smart answer content from search index"
  task :remove_smart_answer_from_search, [:base_path] => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path

    ContentItemPublisher.new.remove_smart_answer_from_search(args.base_path)
  end
end
