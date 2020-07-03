module SmartAnswer::Calculators
  class CoronavirusEmployeeRiskAssessmentCalculator
    WORKPLACES_CLOSED_TO_PUBLIC = %w[
      beauty_parlour
      retail
      auction_house
      nightclubs_or_gambling
      leisure_centre
      indoor_recreation
    ].freeze

    attr_accessor :where_do_you_work,
                  :workplace_is_exception,
                  :are_you_vulnerable,
                  :do_you_live_with_someone_vulnerable,
                  :have_childcare_responsibility

    def workplace_should_be_closed_to_public
      WORKPLACES_CLOSED_TO_PUBLIC.include?(where_do_you_work) && !workplace_is_exception
    end
  end
end
