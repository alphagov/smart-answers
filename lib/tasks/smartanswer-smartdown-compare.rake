require "diffy"

namespace :smartanswer_smartdown do
  desc "Compare the HTML for all listed scenarios of two questions"
  task :compare => :environment do
    result = {}
    SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS = { preload_flows: true }
    SmartdownAdapter::Registry.instance.flows.select { |f| f.transition? }.each do |smartdown_transition_question|
      errors = 0
      helper = SmartdownAdapter::SmartAnswerCompareHelper.new(smartdown_transition_question)

      #Coversheet
      smartanswer_content = helper.get_smartanswer_content
      smartdown_content = helper.get_smartdown_content
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question}"
        p error_message_diff
        errors+=1
      end

      #First question
      smartanswer_content = helper.get_smartanswer_content(true)
      smartdown_content = helper.get_smartdown_content(true)
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
      if smartanswer_content != smartdown_content
        p "Error for coversheet of #{smartdown_transition_question}"
        p error_message_diff
        errors+=1
      end

      #All answer scenarios
      helper.scenario_sequences.each do |responses|
        smartanswer_content = helper.get_smartanswer_content(true, responses)
        begin
          smartdown_content = helper.get_smartdown_content(true, responses)
        rescue Smartdown::Engine::UndefinedValue
          p "Undefined smartdown value for #{responses.join(", ")} for question #{smartdown_transition_question}"
          errors+=1
        rescue Smartdown::Engine::IndeterminateNextNode
          p "Unedefined smartdown next node for #{responses.join(", ")} for question #{smartdown_transition_question}"
          errors+=1
        end
        error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
        if smartanswer_content != smartdown_content
          p "Error for #{responses.join(", ")} for question #{smartdown_transition_question}"
          p error_message_diff
          errors+=1
        end
      end
      result[smartdown_transition_question] = errors
    end
    result.each do |question, number_errors|
      p "#{number_errors} errors for #{question}"
    end
  end
end
