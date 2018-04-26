namespace :marriage_abroad do
  desc "Flatten a set of outcomes for a given country"
  task :flatten_outcomes, [:country] => [:environment] do |_, args|
    MarriageAbroadOutcomeFlattener.new(args[:country]).flatten
  end
end
