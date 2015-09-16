module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      LOAN_MAXIMUMS = {
        "2014-2015" => {
          "at-home" => 4418,
          "away-outside-london" => 5555,
          "away-in-london" => 7751
        },
        "2015-2016" => {
          "at-home" => 4565,
          "away-outside-london" => 5740,
          "away-in-london" => 8009
        }
      }.freeze

      def initialize(course_start:, household_income:, residence:)
        @course_start = course_start
        @household_income = household_income
        @residence = residence
      end

      def maintenance_grant_amount
        return Money.new('0') unless %w(2014-2015 2015-2016).include?(@course_start)

        # 2015-16 rates are the same as 2014-15:
        # max of £3,387 for income up to £25,000 then,
        # £1 less than max for each whole £5.28 above £25000 up to £42,611
        # min grant is £50 for income = £42,620
        # no grant for  income above £42,620
        if @household_income <= 25_000
          Money.new('3387')
        else
          if @household_income > 42_620
            Money.new('0')
          else
            Money.new(3387 - ((@household_income - 25_000) / 5.28).floor)
          end
        end
      end

      def maintenance_loan_amount
        if @household_income <= 42_875
          # reduce maintenance loan by £0.5 for each £1 of maintenance grant
          Money.new(max_maintenance_loan_amount - (maintenance_grant_amount.value / 2.0).floor)
        else
          # reduce maintenance loan by £1 for each full £9.90 of income above £42875 until loan reaches 65% of max, when no further reduction applies
          min_loan_amount = (0.65 * max_maintenance_loan_amount.value).floor # to match the reference table
          reduced_loan_amount = max_maintenance_loan_amount - ((@household_income - 42_875) / 9.59).floor
          if reduced_loan_amount > min_loan_amount
            Money.new(reduced_loan_amount)
          else
            Money.new(min_loan_amount)
          end
        end
      end

    private

      def max_maintenance_loan_amount
        Money.new(LOAN_MAXIMUMS[@course_start][@residence])
      end
    end
  end
end
