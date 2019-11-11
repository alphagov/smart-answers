require "bigdecimal"
module SmartAnswer
  class Money
    include Comparable
    extend Forwardable

    delegate %i[to_f to_s * + - /] => :value

    attr_reader :value

    def initialize(raw_input)
      input = self.class.parse(raw_input)
      self.class.validate!(input)
      @value = BigDecimal(input.to_s)
    end

    def to_s
      @value.to_s
    end

    def <=>(other)
      if other.is_a?(Money)
        @value <=> other.value
      elsif other.is_a?(Numeric)
        @value <=> other
      end
    end

    def self.parse(raw_input)
      if raw_input.is_a?(Numeric)
        raw_input
      else
        raw_input.to_s.delete(",").gsub(/\s/, "").gsub(/£/, "")
      end
    end

    def self.validate!(input)
      unless input.is_a?(Numeric) || input.is_a?(Money) || input =~ /\A *[0-9]+(\.[0-9]{1,2})? *\z/
        raise InvalidResponse, "Sorry, that number is not valid. Please try again.", caller
      end
      if input.to_f.infinite?
        raise InvalidResponse, "Sorry, that number is too big. Please try again.", caller
      end

      true
    end
  end
end
