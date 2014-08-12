module SmartdownAdapter
  class Outcome < Node

    def has_next_steps?
      !!next_steps
    end

    def next_steps
      "not currently possible"
    end

  end
end
