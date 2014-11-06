namespace :smartdown_generate_scenarios do

  class ScenarioGenerator

    def initialize(question_name, answer_combinations)
      @name = question_name
      @combination_generator = SmartdownAdapter::CombinationGenerator.new(question_name, answer_combinations)
    end

    def perform
      combinations = @combination_generator.perform
      combinations.keys.each do |key|
        print_combinations(combinations[key], key)
      end
    end

  private

    def print_combinations(combinations, outcome_name)
      combinations.map do |combination|
        print_combination(combination)
        puts outcome_name
        puts
      end
    end

    def print_combination(combination)
      combination.map do |answer_hash|
        puts "- #{answer_hash.keys.first}: #{answer_hash.values.first}"
      end
    end
  end

  def generate(name, combinations)
    generator = ScenarioGenerator.new(name, combinations)
    generator.perform
  end

  desc "Print scenarios for register_a_birth_transition"
  task :register_a_birth_transition => :environment do
    combinations = {
      :child_country => ["afghanistan", "france", "iran", "north-korea", "south-africa", "sweden"],
      :who_has_british_nationality => ["mother", "father", "mother_and_father", "neither"],
      :married_or_partnership => ["yes", "no"],
      :where_are_you_now => ["same_country", "another_country", "in_the_uk"],
      :child_date_of_birth => ["25-12-2006", "25-12-2007"],
      :registration_country => ["iran", "australia", "france"],
    }
    generate("register-a-birth-transition", combinations)
  end
end
