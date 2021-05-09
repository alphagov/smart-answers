module SmartAnswer
  class StartNode < Node
    PRESENTER_CLASS = StartNodePresenter

    def name
      @flow.name.underscore.to_sym
    end

    def next_node_name(_state)
      @flow.questions.first.name
    end

    def slug
      nil
    end

    def view_template_path
      "smart_answers/landing"
    end
  end
end
