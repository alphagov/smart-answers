SMART_ANSWER_FLOW_PATH = Rails.root.join("app/flows")

namespace :links do
  desc "Checks all URLs within Smart Answers for errors."
  task report: :environment do
    puts BrokenLinkReport.for_erb_files_at(SMART_ANSWER_FLOW_PATH)
  end
end
