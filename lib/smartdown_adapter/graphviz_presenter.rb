module SmartdownAdapter
  class GraphvizPresenter
    def initialize(name)
      @name = name
      @flow = Smartdown::Api::Flow.new(name)
    end

    def to_gv

    end

  end
end
