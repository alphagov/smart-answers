module SmartdownAdapter
  module Utils
    class ScenarioGenerator

      def initialize(question_name, answer_combinations)
        @name = question_name
        @combination_generator = CombinationGenerator.new(question_name, answer_combinations)
      end

      def perform
        combinations = @combination_generator.perform
        output_file = File.new(Rails.root.join("smartdown_data", "scenarios", @name, "generated_scenarios.txt"), "w")
        combinations.keys.each do |key|
          write_combinations(output_file, combinations[key], key)
        end
        output_file.close
      end

    private

      def write_combinations(output_file, combinations, outcome_name)
        combinations.map do |combination|
          combination.map do |answer_hash|
            output_file.puts "- #{answer_hash.keys.first}: #{answer_hash.values.first}"
          end
          output_file.puts outcome_name
          output_file.puts
        end
      end
    end
  end
end
