module Smartdown
  class MultipleChoice < Question
    def options
      question = elements.find{|element| element.is_a? Smartdown::Model::Element::MultipleChoice}
      question.choices.map do |choice|
        OpenStruct.new(:label => choice[1], :value => choice[0])
      end
    end

    def partial_template_name
      "multiple_choice_question"
    end

  end
end
