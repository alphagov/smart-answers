module SmartdownAdapter
  module Utils
    class SmartdownSmartAnswersComparer
      def initialize(smartdown_flow_name, smartanswer_flow_name, answer_sequences)
        @answer_sequences = answer_sequences
        @helper = SmartdownSmartAnswerCompareHelper.new(smartdown_flow_name, smartanswer_flow_name)
      end

      def perform
        errors = []
        #Coversheet
        diff = @helper.diff
        if diff
          errors << "Coversheet error"
          p "COVERSHEET ERROR"
          p diff
        end

        #First question
        diff = @helper.diff(true)
        if diff
          errors << "First question error"
          p "FIRST QUESTION ERROR"
          p diff
        end

        #All answer sequences
        @answer_sequences.each do |answers|
          flattened_answers = answers.flatten
          begin
            diff = @helper.diff(true, flattened_answers)
            if diff
              errors << flattened_answers.join("/")
              p "ERROR FOR #{flattened_answers.join(" ")}"
              p diff
            end
          rescue Smartdown::Engine::UndefinedValue
            errors << "Undefined smartdown value for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          rescue Smartdown::Engine::IndeterminateNextNode
            errors << "Undefined smartdown next node for #{flattened_answers.join(", ")} for question #{smartdown_transition_question_name}"
          end
        end
       errors
      end
    end
  end
end
