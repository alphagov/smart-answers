require "diffy"

namespace :smartanswer_smartdown do
  desc "Compare the HTML for all listed scenarios of two questions"
  task compare: :environment do
    result = {}
    SmartdownAdapter::Registry.instance({ preload_flows: true, show_transitions: true }).flows.select(&:transition?).each do |smartdown_transition_question|
      smartdown_transition_question_name = smartdown_transition_question.name
      errors = 0
      helper = SmartdownAdapter::SmartAnswerCompareHelper.new(smartdown_transition_question)

      #Coversheet
      smartanswer_content = helper.get_smartanswer_content
      smartdown_content = helper.get_smartdown_content
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, context: 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question_name}"
        p error_message_diff
        errors += 1
      end

      #First question
      smartanswer_content = helper.get_smartanswer_content(true)
      smartdown_content = helper.get_smartdown_content(true)
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, context: 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question_name}"
        p error_message_diff
        errors += 1
      end

      #All answer scenarios
      helper.scenario_answer_sequences.each do |answer_groups|
        flattened_answers = answer_groups.flatten
        smartanswer_content = helper.get_smartanswer_content(true, flattened_answers)
        begin
          smartdown_content = helper.get_smartdown_content(true, flattened_answers)
        rescue Smartdown::Engine::UndefinedValue
          p "Undefined smartdown value for #{flattened_answers.join(', ')} for question #{smartdown_transition_question_name}"
          errors += 1
        rescue Smartdown::Engine::IndeterminateNextNode
          p "Unedefined smartdown next node for #{flattened_answers.join(', ')} for question #{smartdown_transition_question_name}"
          errors += 1
        end
        error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, context: 1)
        if smartanswer_content != smartdown_content
          p "Error for #{flattened_answers.join(', ')} for question #{smartdown_transition_question_name}"
          p error_message_diff
          errors += 1
        end
      end
      result[smartdown_transition_question_name] = errors
    end
    result.each do |question, number_errors|
      p "#{number_errors} errors for #{question}"
    end
  end
end
