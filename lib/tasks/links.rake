SMART_ANSWER_FLOW_PATH = Rails.root.join("app/flows")

namespace :links do
  desc "Checks all URLs within Smart Answers for errors."
  task report: :environment do
    puts BrokenLinkReport.for_erb_files_at(SMART_ANSWER_FLOW_PATH)
  end

  # Usage: `rake links:send_report[someone@example.com]
  desc "Checks all URLs within Smart Answers for errors, and send report to Zendesk."
  task :send_report, [:requester_email] => :environment do |_t, args|
    Rails.logger.info "Sending broken link report"

    SupportTicket.send(
      subject: "Smart Answers Broken Link Report: #{Time.zone.today.to_fs(:govuk_date)}",
      body: BrokenLinkReport.for_erb_files_at(SMART_ANSWER_FLOW_PATH),
      requester_email: args.requester_email,
    )
  end
end
