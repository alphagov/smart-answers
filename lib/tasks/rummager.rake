namespace :rummager do
  desc "Indexes all smart answers in Rummager"
  task index: :environment do
    flow_presenters = RegisterableSmartAnswers.new.flow_presenters
    RummagerNotifier.new(flow_presenters).notify
  end
end
