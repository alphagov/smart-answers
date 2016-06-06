module SmartAnswer::Calculators
  class EnergyGrantsCalculator
    include ActiveModel::Model

    attr_accessor :which_help
    attr_accessor :circumstances

    def initialize(attributes = {})
      super
      @circumstances ||= []
    end
  end
end
