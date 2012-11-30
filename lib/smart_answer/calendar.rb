require 'ics_renderer'

module SmartAnswer
  class Calendar

    attr_reader :dates

    def initialize(&block)
      @dates = []
      @block = block if block_given?
    end

    def evaluate(state)
      @path = state.path.join('/')
      instance_exec(state, &@block) if @block and !@dates.any?
      return self
    end

    def date(name, date_or_range)
      @dates << OpenStruct.new(:title => name, :date => date_or_range)
    end

    def to_ics
      ICSRenderer.new(dates, @path).render
    end

  end
end
