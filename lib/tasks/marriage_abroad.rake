namespace :marriage_abroad do
  desc "Flatten a set of outcomes for a given country"
  task :flatten_outcomes, %i[country same_sex_wording] => [:environment] do |_, args|
    unless %w(same_sex_marriage civil_partnership).include?(args[:same_sex_wording])
      raise ArgumentError.new("Same-sex wording must be same_sex_marriage or civil_partnership")
    end

    flattener = MarriageAbroadOutcomeFlattener.new(
      args[:country],
      same_sex_wording: args[:same_sex_wording].to_sym,
    )

    flattener.flatten
  end
end
