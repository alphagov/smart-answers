require 'bigdecimal'
module SmartAnswer
  class Money
    include Comparable
    extend Forwardable

    delegate [:to_f, :to_s, :*, :+, :-, :/] => :value

    attr_reader :value

    def initialize(raw_input)
      if raw_input.is_a?(Numeric)
        @value = BigDecimal.new(raw_input.to_s)
      else
        raw_input = raw_input.to_s.delete(',').gsub(/\s/, '')
        if !self.class.valid?(raw_input)
          raise InvalidResponse, "Sorry, I couldn't understand that number. Please try again.", caller
        end
        @value = BigDecimal.new(raw_input.to_s)
      end
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

    def self.valid?(raw_input)
      raw_input.is_a?(Numeric) || raw_input.is_a?(Money) || raw_input =~ /\A *[0-9]+(\.[0-9]{1,2})? *\z/
    end
  end
end
