module SmartAnswer
  module Calculators
    class PersonalAllowanceCalculator
      delegate :personal_allowance, to: :rates

      delegate :income_limit_for_personal_allowances, to: :rates

    private

      def rates
        @rates ||= RatesQuery.from_file("personal_allowance").rates
      end
    end
  end
end
