module SmartAnswer::Calculators
  class EnergyGrantsCalculator
    include ActiveModel::Model

    attr_accessor :which_help
    attr_accessor :circumstances
    attr_accessor :date_of_birth
    attr_accessor :benefits_claimed
    attr_accessor :disabled_or_have_children
    attr_accessor :property_age
    attr_accessor :property_type
    attr_accessor :flat_type
    attr_accessor :features

    def initialize(attributes = {})
      super
      @circumstances ||= []
      @benefits_claimed ||= []
      @features ||= []
    end

    def may_qualify_for_affordable_warmth_obligation?
      disabled_or_have_children != 'none' && benefits_claimed.include?('universal_credit')
    end
  end
end
