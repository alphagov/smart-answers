module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    attr_accessor :location_of_death
    attr_accessor :death_location_type

    def died_in_uk?
      %w(england_wales scotland northern_ireland).include?(location_of_death)
    end
  end
end
