namespace :register_a_birth_transition do

  task :generate_scenarios => :environment do
    combinations = {
      :child_country => ["afghanistan", "france", "iran", "north-korea", "south-africa", "sweden"],
      :who_has_british_nationality => ["mother", "father", "mother_and_father", "neither"],
      :married_or_partnership => ["yes", "no"],
      :where_are_you_now => ["same_country", "another_country", "in_the_uk"],
      :child_date_of_birth => ["25-12-2006", "25-12-2007"],
      :registration_country => ["iran", "australia", "france"],
    }
    generator = SmartdownAdapter::Utils::ScenarioGenerator.new("register-a-birth-transition", combinations)
    generator.perform
  end

  task :generate_combinations => :environment do
    def write_to_combination_file(file_name, content)
      output_file = File.open(Rails.root.join("smartdown_data", "combinations", "#{file_name}.txt"), "a")
      output_file.puts content
      output_file.close
    end
    def unique_entries_in_file(file_name)
      lines = File.readlines(Rails.root.join("smartdown_data", "combinations", "register-a-birth-transition", "#{file_name}.txt"))
      lines.uniq!
      file = File.open(Rails.root.join("smartdown_data", "combinations", "register-a-birth-transition", "#{file_name}.txt"), "w")
      lines.each do |line|
        file.puts line
      end
      file.close
    end
    world_slugs = WorldLocation.all.map do |world_location|
      world_location.details.slug unless %w(holy-see british-antarctic-territory).include? world_location.details.slug
    end.compact
    world_slugs.each do |world_location|
      #unique_entries_in_file(world_location)
      #world_slugs.each do |world_location_2|
        answer_combinations = {
          :child_country => [ world_location ],
          :married_or_partnership => ["yes", "no"],
          :child_date_of_birth => ["25-12-2005", "25-12-2007"],
          #:registration_country => [ world_location_2 ],
          :where_are_you_now => ["same_country", "in_the_uk"],#, "another_country"],
          :who_has_british_nationality => ["mother", "father", "mother_and_father", "neither"]
        }
        combination_generator = SmartdownAdapter::Utils::CombinationGenerator.new("register-a-birth-transition", answer_combinations)
        combinations = combination_generator.perform_and_format
        combinations.each do |combination|
          write_to_combination_file(world_location, combination.join("/"))
        end
      #end
    end
  end

  task :compare_to_smartanswer_from_scenarios => :environment do
    answers = []
    smartdown_flow = SmartdownAdapter::Registry.instance.find("register-a-birth-transition")
    smartdown_flow.scenario_sets.each do |scenario_set|
      scenario_set.scenarios.each_with_index do |scenario, scenario_index|
        scenario.question_groups.each_with_index do |question_group, question_index|
          answers << scenario.question_groups[0..question_index].flatten.map(&:answer)
        end
      end
    end
    comparer = SmartdownAdapter::Utils::SmartdownSmartAnswersComparer.new(
      "register-a-birth-transition",
      "register-a-birth",
      answers
    )
    errors = comparer.perform
    p "#{errors.count} ERRORS"
    write_to_error_file("scenarios", errors)
  end

  task :compare_to_smartanswer_from_combinations => :environment do
    Dir[Rails.root.join("smartdown_data", "combinations", "register-a-birth-transition", "*")].each do |file|
      lines = File.readlines(file)
      lines.map do |line|
        answer = line.split("/").map(&:strip)
        comparer = SmartdownAdapter::Utils::SmartdownSmartAnswersComparer.new(
          "register-a-birth-transition",
          "register-a-birth",
          [answer]
        )
        errors = comparer.perform
        write_to_error_file("combinations", errors)
      end
    end
  end

  task :compare_to_smartanswer_from_errors => :environment do
    answers = []
    Dir[Rails.root.join("smartdown_data", "errors", "register-a-birth-transition", "*")].each do |file|
      lines = File.readlines(file)
      answers += lines.map do |line|
        line.split("/").map(&:strip)
      end
    end
    comparer = SmartdownAdapter::Utils::SmartdownSmartAnswersComparer.new(
      "register-a-birth-transition",
      "register-a-birth",
      answers
    )
    errors = comparer.perform
    p "#{errors.count} ERRORS"
    write_to_error_file("errors", errors)
  end

  def write_to_error_file(origin, errors)
    output_file = File.open(Rails.root.join("smartdown_data", "errors", "register-a-birth-transition", "#{origin}_errors.txt"), "a")
    errors.each do |error|
      output_file.puts error
    end
    output_file.close
  end
end
