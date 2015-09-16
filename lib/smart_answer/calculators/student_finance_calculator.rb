module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      LOAN_MAXIMUMS = {
        "2014-2015" => {
          "at-home" => 4_418,
          "away-outside-london" => 5_555,
          "away-in-london" => 7_751
        },
        "2015-2016" => {
          "at-home" => 4_565,
          "away-outside-london" => 5_740,
          "away-in-london" => 8_009
        },
        "2016-2017" => {
          "at-home" => 6_904,
          "away-outside-london" => 8_200,
          "away-in-london" => 10_702
        }
      }.freeze

      delegate :maintenance_loan_amount, :maintenance_grant_amount, to: :strategy

      def initialize(course_start:, household_income:, residence:)
        @course_start = course_start
        @household_income = household_income
        @residence = residence
      end

    private

      def legacy_scheme?
        %w(2014-2015 2015-2016).include?(@course_start)
      end

      def strategy
        @strategy ||= begin
          klass = legacy_scheme? ? LegacyStrategy : Strategy
          klass.new(
            course_start: @course_start,
            household_income: @household_income,
            residence: @residence
          )
        end
      end

      class Strategy
        LOAN_MINIMUMS = {
          "2016-2017" => {
            "at-home" => 3_039,
            "away-outside-london" => 3_821,
            "away-in-london" => 5_330
          }
        }.freeze
        INCOME_PENALTY_RATIO = {
          "2016-2017" => {
            "at-home" => 8.59,
            "away-outside-london" => 8.49,
            "away-in-london" => 8.34
          }
        }

        def initialize(course_start:, household_income:, residence:)
          @course_start = course_start
          @household_income = household_income
          @residence = residence
        end

        def maintenance_grant_amount
          Money.new('0')
        end

        def maintenance_loan_amount
          reduced_amount = max_loan_amount - reduction_based_on_income
          Money.new([reduced_amount, min_loan_amount].max)
        end

      private

        def max_loan_amount
          LOAN_MAXIMUMS[@course_start][@residence]
        end

        def min_loan_amount
          LOAN_MINIMUMS[@course_start][@residence]
        end

        def reduction_based_on_income
          return 0 if @household_income <= 25_000

          ratio = INCOME_PENALTY_RATIO[@course_start][@residence]
          ((@household_income - 25_000) / ratio).floor
        end
      end

      class LegacyStrategy
        def initialize(course_start:, household_income:, residence:)
          @course_start = course_start
          @household_income = household_income
          @residence = residence
        end

        def maintenance_grant_amount
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
            Money.new(max_loan_amount - (maintenance_grant_amount.value / 2.0).floor)
          else
            # reduce maintenance loan by £1 for each full £9.90 of income above £42875 until loan reaches 65% of max, when no further reduction applies
            min_loan_amount = (0.65 * max_loan_amount.value).floor # to match the reference table
            reduced_loan_amount = max_loan_amount - ((@household_income - 42_875) / 9.59).floor
            if reduced_loan_amount > min_loan_amount
              Money.new(reduced_loan_amount)
            else
              Money.new(min_loan_amount)
            end
          end
        end

      private

        def max_loan_amount
          Money.new(LOAN_MAXIMUMS[@course_start][@residence])
        end
      end
    end
  end
end
