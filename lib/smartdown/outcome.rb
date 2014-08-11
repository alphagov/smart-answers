module Smartdown
  class Outcome < Node

    def has_next_steps?
      !!next_steps
    end

    def next_steps
      next_step_element = elements.find{|element| element.is_a? Smartdown::Model::Element::NextSteps}
      GovspeakPresenter.new(next_step_element.content).html if next_step_element
    end

  end
end
