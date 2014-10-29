module SmartdownAdapter
  class SplFactcheckGenerator

    def initialize(question_name, due_or_match_date, answer_combinations, human_readable_snippet_names)
      @name = question_name
      @due_or_match_date = due_or_match_date
      @combination_generator = CombinationGenerator.new(question_name, answer_combinations)
      @human_readable_snippet_names = human_readable_snippet_names
    end

    def perform
      combinations = @combination_generator.perform
      smartdown_factcheck_path = File.join(smartdown_factcheck_path(@name))
      generate_factcheck_files(combinations, smartdown_factcheck_path)
    end

  private

    def generate_factcheck_files(combinations, smartdown_factcheck_path)
      combination_hashes = []
      combinations.keys.each do |key|
        combination_hashes += combinations[key].map do |combination|
          combination_hash = {}
          combination.each do |answer_hash|
            combination_hash[answer_hash.keys.first] = answer_hash.values.first
          end
          combination_hash.merge(:outcome => key)
        end
      end
      adoption_hashes = combination_hashes.select do |combination_hash|
        combination_hash[:circumstance] == "adoption"
      end
      birth_hashes = combination_hashes.select do |combination_hash|
        combination_hash[:circumstance] == "birth"
      end
      unique_adoption_hashes = adoption_hashes.uniq
      unique_birth_hashes = birth_hashes.uniq
      node_filepath = File.join(smartdown_factcheck_path, "factcheck", "birth_factcheck_#{@due_or_match_date}.md")
      File.write(node_filepath, format_birth_hashes(unique_birth_hashes))
      node_filepath = File.join(smartdown_factcheck_path, "factcheck", "adoption_factcheck_#{@due_or_match_date}.md")
      File.write(node_filepath, format_adoption_hashes(unique_adoption_hashes))
    end

    def format_adoption_hashes(adoption_hashes)
      ordered_adoption_hashes = order_adoption_hashes(adoption_hashes)
      lines = []
      lines << "##Adoption \n"
      lines << "Nb | PA status | PA C | PA LE | PA W | PA E&E | P status | P C | P LE | P W | P E&E | Outcome | URL"
      lines << "-|-"
      line_content = []
      ordered_adoption_hashes.each do |adoption_hash|
        line_content << format_adoption_hash(adoption_hash)
      end
      unique_line_content = remove_duplicate_circumstances(line_content)
      lines += unique_line_content.each.with_index(1).map{ |line_array, i| ([i]+line_array).join(" | ") }
      lines.uniq.join("\n")
    end

    def format_birth_hashes(birth_hashes)
      ordered_birth_hashes = order_birth_hashes(birth_hashes)
      lines = []
      lines << "##Birth \n"
      lines << "Nb | M status | M C | M LE | M W | M E&E | P status | P C | P LE | P W | P E&E | Outcome | URL"
      lines << "-|-"
      line_content = []
      ordered_birth_hashes.each do |birth_hash|
        line_content << format_birth_hash(birth_hash)
      end
      unique_line_content = remove_duplicate_circumstances(line_content)
      lines += unique_line_content.each.with_index(1).map{ |line_array, i| ([i]+line_array).join(" | ") }
      lines.uniq.join("\n")
    end

    def format_adoption_hash(adoption_hash)
      result = []
      result << adoption_hash[:employment_status_1]
      if adoption_hash[:job_before_x_1]
        result << tick_or_cross(adoption_hash[:job_before_x_1] == "yes" && adoption_hash[:job_after_y_1] == "yes")
        result << tick_or_cross(adoption_hash[:ler_1] == "yes")
        result << tick_or_cross(adoption_hash[:job_after_y_1] == "yes")
      else
        result += [nil, nil, nil]
      end
      result << tick_or_cross(adoption_hash[:earnings_employment_1])
      result << adoption_hash[:employment_status_2]
      if adoption_hash[:job_before_x_2]
        result << tick_or_cross(adoption_hash[:job_before_x_2] == "yes" && adoption_hash[:job_after_y_2] == "yes")
        result << tick_or_cross(adoption_hash[:ler_2] == "yes")
        result << tick_or_cross(adoption_hash[:job_after_y_2] == "yes")
      else
        result += [nil, nil, nil]
      end
      result << tick_or_cross(adoption_hash[:earnings_employment_2])
      result << human_readable_description(adoption_hash[:outcome])
      result << url_from_hash(adoption_hash)
      result
    end

    def format_birth_hash(birth_hash)
      result = []
      result << birth_hash[:employment_status_1]
      if birth_hash[:job_before_x_1]
        result << tick_or_cross(birth_hash[:job_before_x_1] == "yes" && birth_hash[:job_after_y_1] == "yes")
        result << tick_or_cross(birth_hash[:ler_1] == "yes")
        result << tick_or_cross(birth_hash[:job_after_y_1] == "yes")
      else
        result << [nil, nil, nil]
      end
      result << tick_or_cross(birth_hash[:earnings_employment_1])
      result << birth_hash[:employment_status_2]
      if birth_hash[:job_before_x_2]
        result << tick_or_cross(birth_hash[:job_before_x_2] == "yes" && birth_hash[:job_after_y_2] == "yes")
        result << tick_or_cross(birth_hash[:ler_2] == "yes")
        result << tick_or_cross(birth_hash[:job_after_y_2] == "yes")
      else
        result << [nil, nil, nil]
      end
      result << tick_or_cross(birth_hash[:earnings_employment_2])
      result << human_readable_description(birth_hash[:outcome])
      result << url_from_hash(birth_hash)
      result
    end

    def order_adoption_hashes(hashes)
      hashes.sort { |a,b|
        [a[:match_date], a[:employment_status_1], a[:employment_status_2] || ""]  <=> [b[:match_date], b[:employment_status_1], b[:employment_status_2] || ""]
       }
    end

    def order_birth_hashes(hashes)
      hashes.sort { |a,b|
        [a[:due_date], a[:employment_status_1], a[:employment_status_2] || ""]  <=> [b[:due_date], b[:employment_status_1], b[:employment_status_2] || ""]
      }
    end

    def url_from_hash(hash)
      "[link](https://www.preview.alphagov.co.uk/employee-parental-leave/y/#{hash.values[0..-2].join("/")})"
    end

    def remove_duplicate_circumstances(line_content_array)
      #Identical legal circumstances will have different URLs
      #Omit last element of the line content (URL) to determine unicity
      grouped_line_content = line_content_array.group_by { |line_content| line_content[0..-2] }
      grouped_line_content.values.map(&:first)
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
      elsif predicate == false
        10008.chr
      end
    end

  end
end
