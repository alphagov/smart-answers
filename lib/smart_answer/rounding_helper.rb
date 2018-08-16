module SmartAnswer
  module RoundingHelper
    def round_up_to_the_next_pence(value)
      (value * 100).truncate(1).ceil / 100.0
    end
  end
end
