module SmartdownAdapter
  class ScenarioGenerator

    def initialize(question_name, answer_combinations)
      @name = question_name
      @combination_generator = CombinationGenerator.new(question_name, answer_combinations)
    end

    def perform
      combinations = @combination_generator.perform
      smartdown_factcheck_path = File.join(smartdown_factcheck_path(@name))
      combinations.keys.each do |key|
        node_filepath = File.join(smartdown_factcheck_path, "scenarios", "#{key}.txt")
        File.write(node_filepath, format_combinations(combinations[key]))
      end
    end

  private

    def format_combinations(combinations)
      combinations.map do |combination|
        format_combination(combination)
      end.join("\n\n")+"\n"
    end

    def format_combination(combination)
      combination.map do |answer_hash|
        "#{answer_hash.keys.first}: #{answer_hash.values.first}"
      end.join("\n")
    end
  end
end
