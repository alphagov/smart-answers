module SmartAnswer::Calculators
  class CoronavirusEmployeeRiskAssessmentCalculator
    WORKPLACES_CLOSED_TO_PUBLIC = %w[
      food_and_drink
      retail
      auction_house
      nightclubs_or_gambling
      indoor_recreation
    ].freeze

    WORKPLACES_OPENING_SOON_TO_PUBLIC = {}.freeze

    attr_accessor :where_do_you_work,
                  :workplace_is_exception,
                  :are_you_vulnerable,
                  :do_you_live_with_someone_vulnerable,
                  :have_childcare_responsibility

    def workplace_should_be_closed_to_public
      WORKPLACES_CLOSED_TO_PUBLIC.include?(where_do_you_work) && !workplace_is_exception
    end

    def workplace_opening_date
      WORKPLACES_OPENING_SOON_TO_PUBLIC[where_do_you_work] unless workplace_is_exception
    end
  end
end
