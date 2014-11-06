require "diffy"

namespace :smartanswer_smartdown do
  desc "Compare the HTML for all listed scenarios of two questions"
  task :compare => :environment do
    result = {}
    SmartdownAdapter::Registry.instance({ preload_flows: true, show_transitions: true }).flows.select { |f| f.transition? }.each do |smartdown_transition_question|
      smartdown_transition_question_name = smartdown_transition_question.name
      errors = 0
      helper = SmartdownAdapter::SmartAnswerCompareHelper.new(smartdown_transition_question)

      #Coversheet
      smartanswer_content = helper.get_smartanswer_content
      smartdown_content = helper.get_smartdown_content
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question_name}"
        p error_message_diff
        errors+=1
      end

      #First question
      smartanswer_content = helper.get_smartanswer_content(true)
      smartdown_content = helper.get_smartdown_content(true)
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question_name}"
        p error_message_diff
        errors+=1
      end

      #All answer scenarios
      scenario_answer_sequences.each do |answer_groups|
        flattened_answers = answer_groups.flatten
        smartanswer_content = helper.get_smartanswer_content(true, flattened_answers)
        begin
          smartdown_content = helper.get_smartdown_content(true, flattened_answers)
        rescue Smartdown::Engine::UndefinedValue
          p "Undefined smartdown value for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          errors+=1
        rescue Smartdown::Engine::IndeterminateNextNode
          p "Unedefined smartdown next node for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          errors+=1
        end
        error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
        if smartanswer_content != smartdown_content
          p "Error for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          p error_message_diff
          errors+=1
        end
      end
      result[smartdown_transition_question_name] = errors
    end
    result.each do |question, number_errors|
      p "#{number_errors} errors for #{question}"
    end
  end

  task :compare_birth_all_cases => :environment do
    errors = 0
    smartdown_transition_question_name = "register-a-birth-transition"
    exceptions = {}
    exceptions["Overseas Registration Unit<br>Foreign and Commonwealth Office<br>PO Box 6255<br>Milton Keynes<br>MK10 1XX<br></p></div></div>"] =
      "  Overseas Registration Unit<br>  Foreign and Commonwealth Office<br>  PO Box 6255<br>  Milton Keynes<br>  MK10 1XX<br></p></div></div>"
    exceptions["Overseas Registration Unit<br>Foreign &amp; Commonwealth Office<br>Hanslope Park<br>Hanslope<br>Milton Keynes<br>MK19 7BH<br>United Kingdom<br></p></div></div>"] =
      "  Overseas Registration Unit<br>  Foreign &amp; Commonwealth Office<br>  Hanslope Park<br>  Hanslope<br>  Milton Keynes<br>  MK19 7BH<br>  United Kingdom<br></p></div></div>"
    helper = SmartdownAdapter::SmartAnswerCompareHelper.new(
      OpenStruct.new(:name => smartdown_transition_question_name),
      exceptions,
      "register-a-birth"
    )

    WorldLocation.all.each do |world_location|
      p "#{world_location.details.slug} "
      answer_combinations = {
        :child_country => [ world_location.details.slug ],
        :married_or_partnership => ["yes", "no"],
        :child_date_of_birth => ["25-12-2005", "25-12-2007"],
        :registration_country => WorldLocation.all.map { |location| location.details.slug },
        :where_are_you_now => ["same_country", "in_the_uk", "another_country"],
        :who_has_british_nationality => ["mother", "father", "mother_and_father", "neither"]
      }
      combination_generator = SmartdownAdapter::CombinationGenerator.new(smartdown_transition_question_name, answer_combinations)
      combinations = combination_generator.perform

      answers = []
      combinations.each do |key, question_hash_array_collection|
        question_hash_array_collection.each do |question_hash_array|
          question_answers = question_hash_array.map do |question_hash|
            question_hash.values.first
          end
          answers << question_answers
        end
      end
      answers.uniq!

      #All answer scenarios
      answers.each do |answer_groups|
        flattened_answers = answer_groups.flatten
        smartanswer_content = helper.get_smartanswer_content(true, flattened_answers)
        begin
          smartdown_content = helper.get_smartdown_content(true, flattened_answers)
        rescue Smartdown::Engine::UndefinedValue
          p "Undefined smartdown value for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          errors+=1
        rescue Smartdown::Engine::IndeterminateNextNode
          p "Undefined smartdown next node for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          errors+=1
        end
        error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
        if smartanswer_content != smartdown_content
          p "#{flattened_answers.join("/")}"
          p error_message_diff
          errors+=1
        end
      end
    end
  end
end
