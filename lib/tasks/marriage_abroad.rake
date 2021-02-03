namespace :marriage_abroad do
  desc "Flatten a set of outcomes for a given country"
  task :flatten_outcomes, %i[country] => [:environment] do |_, args|
    ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.gov.uk"
    ENV["PLEK_SERVICE_CONTENT_STORE_URI"] ||= "https://www.gov.uk/api"
    MarriageAbroadOutcomeFlattener.new(args[:country]).flatten
  end
end
