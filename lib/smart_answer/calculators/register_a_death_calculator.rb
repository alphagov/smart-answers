module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    attr_accessor :location_of_death
    attr_accessor :death_location_type
    attr_accessor :death_expected

    def died_in_uk?
      %w(england_wales scotland northern_ireland).include?(location_of_death)
    end

    def died_at_home_or_in_hospital?
      death_location_type == 'at_home_hospital'
    end

    def death_expected?
      death_expected == 'yes'
    end
  end
end
