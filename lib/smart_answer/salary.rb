module SmartAnswer
  class Salary
    include Comparable

    attr_reader :amount, :period

    def initialize(amount_or_options = {}, period = nil)
      if amount_or_options.is_a?(Hash)
        amount = amount_or_options[:amount]
        period = amount_or_options[:period]
      elsif amount_or_options.to_s.match(/^[0-9\.]+-[a-z]+$/)
        amount, period = amount_or_options.to_s.split('-')
      else
        amount = amount_or_options
      end
      @amount = Money.new(amount)
      @period = period || 'week'
      raise InvalidResponse, "Sorry, I couldn't understand that salary period", caller unless %w{year month week}.include?(@period)
    end

    def <=>(other)
      return nil unless other.is_a?(Salary)
      return nil unless other.period == self.period
      self.amount <=> other.amount
    end

    def to_s
      "#{@amount}-#{@period}"
    end

    def per_week
      case @period
      when "week"
        @amount
      when "month"
        Money.new((@amount.value * 12) / 52)
      when "year"
        Money.new(@amount.value / 52)
      end
    end
  end
end
