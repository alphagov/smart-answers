module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    attr_reader :travelling_with_children
    attr_accessor :countries, :vaccination_status, :any_other_countries

    MAX_COUNTRIES = 99

    def initialize
      @countries = []
      @travelling_with_children = []
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def travelling_with_children=(travelling_with_children)
      travelling_with_children.split(",").each do |response|
        @travelling_with_children << response
      end
    end
  end
end
