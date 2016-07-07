module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    attr_accessor :location_of_death
  end
end
