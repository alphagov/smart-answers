module SmartdownAdapter
  class Registry

    def self.check(name)
      use_smartdown_question = false
      smartdown_questions = ["animal-example"]
      if smartdown_questions.include? name
        smartdown_flow = Flow.new(name)
        show_drafts = FLOW_REGISTRY_OPTIONS.fetch(:show_drafts, false)
        show_transitions = FLOW_REGISTRY_OPTIONS.fetch(:show_transitions, false)
        use_smartdown_question = (smartdown_flow && smartdown_flow.draft? && show_drafts) ||
        (smartdown_flow && smartdown_flow.transition? && show_transitions) || (smartdown_flow && smartdown_flow.published?)
      end
      use_smartdown_question
    end
  end
end
