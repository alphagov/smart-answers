module SmartdownAdapter
  class ScenarioGenerator

    def initialize(question_name, answer_combinations, human_readable_snippet_names)
      @question_name = question_name
      @answer_combinations = answer_combinations
      @human_readable_snippet_names = human_readable_snippet_names
      @errors = []
      @answer_hashes = {}
      @outcomes = {}
    end

    def perform
      smartdown_flow = Registry.instance.find(@question_name)
      combinations = generate_start_combinations(smartdown_flow)
      until combinations.empty? do
        combinations = generate_next_combinations(smartdown_flow, combinations)
      end
      p "#{@errors.count/2} errors"
      @errors.each do |error|
        puts error
      end
      smartdown_flow_path = File.join(smartdown_flow_path(smartdown_flow.name))
      humanized_combinations(@outcomes, smartdown_flow_path)
      @outcomes.keys.each do |key|
        node_filepath = File.join(smartdown_flow_path, "scenarios", "#{key}.txt")
        File.write(node_filepath, format_combinations(@outcomes[key]))
      end
    end

  private

    def generate_start_combinations(smartdown_flow)
      state = smartdown_flow.state(true, [])
      questions = state.current_node.elements.select do |element|
        element.class.to_s.include?("Smartdown::Model::Element::Question")
      end
      question_keys = questions.map(&:name).map(&:to_sym)
      answer_combinations(question_keys)
    end

    def generate_next_combinations(smartdown_flow, combinations)
      new_combinations = []
      combinations.each_with_index do |combination, combination_index|
        answers = combination.map do |hash|
          hash.values.first
        end
        begin
          state = smartdown_flow.state(true, answers)
          if state.current_node.is_a? Smartdown::Api::QuestionPage
            questions = state.current_node.elements.select do |element|
              element.class.to_s.include?("Smartdown::Model::Element::Question")
            end
            question_keys = questions.map(&:name).map(&:to_sym)
            answer_combinations = answer_combinations(question_keys)
            answer_combinations.each do |answer_combination|
              new_combinations << combination + answer_combination
            end
          else
            if @outcomes[state.current_node.name]
              @outcomes[state.current_node.name] << combination
            else
              @outcomes[state.current_node.name] = [combination]
            end
          end
        rescue Exception => e
          @errors << e.to_s
          @errors << combination
        end
      end
      new_combinations
    end

    def answer_combinations(question_keys)
      @answer_hashes[question_keys] || generate_answer_combinations(question_keys)
    end

    def generate_answer_combinations(question_keys)
      combinations = []
      first_question_answers = @answer_combinations.fetch(question_keys.first)
      first_question_answers.each do |answer|
        combinations << [{ question_keys.first => answer }]
      end
      question_keys.last(question_keys.length-1).each do |question_key|
        answers = @answer_combinations.fetch(question_key)
        new_combinations = []
        combinations.each do |combination|
          answers.each do |answer|
            new_combinations << combination + [{ question_key => answer }]
          end
        end
        combinations = new_combinations
      end
      @answer_hashes[question_keys] = combinations
      combinations
    end

    def format_combinations(combinations)
      combinations.map do |combination|
        format_combination(combination)
      end.join("\n\n")
    end

    def humanized_combinations(outcomes, smartdown_flow_path)
      combination_hashes = []
      outcomes.keys.each do |key|
        outcomes[key].each do |combination|
          combination_hashes << combination.inject(:update).merge(:outcome => key)
        end
      end
      adoption_hashes = combination_hashes.select do |combination_hash|
        combination_hash[:circumstance] == "adoption"
      end
      birth_hashes = combination_hashes.select do |combination_hash|
        combination_hash[:circumstance] == "birth"
      end
      node_filepath = File.join(smartdown_flow_path, "factcheck", "birth_factcheck.txt")
      File.write(node_filepath, format_birth_hashes(birth_hashes))
      node_filepath = File.join(smartdown_flow_path, "factcheck", "adoption_factcheck.txt")
      File.write(node_filepath, format_adoption_hashes(adoption_hashes))
    end

    def format_combination(combination)
      combination.map do |answer_hash|
        "#{answer_hash.keys.first}: #{answer_hash.values.first}"
      end.join("\n")
    end

    def format_adoption_hashes(adoption_hashes)
      lines = []
      lines << "##Adoption \n"
      lines << "Match date | Principal adopter status | PA: Continuity | PA: E&E | Partner status | P: Continuity | P: E&E | Outcome"
      lines << "-|-"
      adoption_hashes.each do |adoption_hash|
        lines << format_adoption_hash(adoption_hash)
      end
      lines.uniq.join("\n")
    end

    def format_birth_hashes(birth_hashes)
      lines = []
      lines << "##Birth \n"
      lines << "Due date | Mother status | M: Continuity | M: E&E | Partner status | P: Continuity | P: E&E | Outcome"
      lines << "-|-"
      birth_hashes.each do |birth_hash|
        lines << format_birth_hash(birth_hash)
      end
      lines.uniq.join("\n")
    end

    def format_adoption_hash(adoption_hash)
      result = ""
      result += "#{format_date(adoption_hash[:match_date])} |"
      result += "#{adoption_hash[:employment_status_1]} |"
      result += "#{tick_or_cross(adoption_hash[:job_before_x_1] == "yes" && adoption_hash[:job_after_y_1] == "yes" && adoption_hash[:ler_1] == "yes") } |"
      result += "#{tick_or_cross(adoption_hash[:earnings_employment_1])} |"
      result += "#{adoption_hash[:employment_status_2]} |"
      result += "#{tick_or_cross(adoption_hash[:job_before_x_2] == "yes" && adoption_hash[:job_after_y_2] == "yes" && adoption_hash[:ler_2] == "yes") } |"
      result += "#{tick_or_cross(adoption_hash[:earnings_employment_2])} |"
      result += "#{human_readable_description(adoption_hash[:outcome])}"
      result
    end

    def format_birth_hash(birth_hash)
      result = ""
      result += "#{format_date(birth_hash[:due_date])} |"
      result += "#{birth_hash[:employment_status_1]} |"
      result += "#{tick_or_cross(birth_hash[:job_before_x_1] == "yes" && birth_hash[:job_after_y_1] == "yes" && birth_hash[:ler_1] == "yes") } |"
      result += "#{tick_or_cross(birth_hash[:earnings_employment_1])} |"
      result += "#{birth_hash[:employment_status_2]} |"
      result += "#{tick_or_cross(birth_hash[:job_before_x_2] == "yes" && birth_hash[:job_after_y_2] == "yes" && birth_hash[:ler_2] == "yes") } |"
      result += "#{tick_or_cross(birth_hash[:earnings_employment_2])} |"
      result += "#{human_readable_description(birth_hash[:outcome])}"
      result
    end

    def human_readable_description(outcome_name)
      outcome_name.split("_")[1..-1].map do |snippet_name|
        "- " + @human_readable_snippet_names.fetch(snippet_name)
      end.join("<br>")
    end

    def format_date(date_string)
      date = Date.parse(date_string)
      date.strftime("%d/%m/%Y")
    end

    def tick_or_cross(predicate)
      if predicate
        (predicate == true || predicate == 'yes') ? 10004.chr : 10008.chr
      end
    end

  end
end
