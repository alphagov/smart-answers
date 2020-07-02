module SmartAnswer::Calculators
  class CoronavirusEmployeeRiskAssessmentCalculator
    attr_accessor :where_do_you_work,
                  :workplace_is_exception,
                  :are_you_vulnerable,
                  :do_you_live_with_someone_vulnerable,
                  :have_childcare_responsibility

    def workplace_should_be_closed_to_public
      where_do_you_work != "other" && !workplace_is_exception
    end
  end
end
