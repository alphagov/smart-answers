module SmartdownAdapter
  class SplFactcheckGenerator

    def initialize(question_name, answer_combinations, human_readable_snippet_names)
      @name = question_name
      @combination_generator = CombinationGenerator.new(question_name, answer_combinations)
      @human_readable_snippet_names = human_readable_snippet_names
    end

    def perform
      combinations = @combination_generator.perform
      smartdown_factcheck_path = File.join(smartdown_factcheck_path(@name))
      generate_factcheck_files(combinations, smartdown_factcheck_path)
    end

  private

    def generate_factcheck_files(outcomes, smartdown_factcheck_path)
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
      node_filepath = File.join(smartdown_factcheck_path, "factcheck", "birth_factcheck.txt")
      File.write(node_filepath, format_birth_hashes(birth_hashes))
      node_filepath = File.join(smartdown_factcheck_path, "factcheck", "adoption_factcheck.txt")
      File.write(node_filepath, format_adoption_hashes(adoption_hashes))
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
