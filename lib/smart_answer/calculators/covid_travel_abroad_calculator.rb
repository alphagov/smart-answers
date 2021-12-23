module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    attr_reader :travelling_with_children

    def initialize
      @travelling_with_children = []
    end

    def travelling_with_children=(travelling_with_children)
      travelling_with_children.split(",").each do |response|
        @travelling_with_children << response
      end
    end
  end
end
