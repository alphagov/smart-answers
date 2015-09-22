module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      LOAN_MAXIMUMS = {
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
        %w(2015-2016).include?(@course_start)
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
          return Money.new('3387') if @household_income <= 25_000
          return Money.new('0') if @household_income > 42_620
          Money.new(3387 - grant_reduction_based_on_income)
        end

        def maintenance_loan_amount
          if @household_income <= 42_875
            Money.new(max_loan_amount - (maintenance_grant_amount.value * 0.5).floor)
          else
            reduced_loan_amount = max_loan_amount - loan_reduction_based_on_income
            Money.new([reduced_loan_amount, min_loan_amount].max)
          end
        end

      private

        def loan_reduction_based_on_income
          ((@household_income - 42_875) / 9.59).floor
        end

        def grant_reduction_based_on_income
          ((@household_income - 25_000) / 5.28).floor
        end

        def min_loan_amount
          (0.65 * max_loan_amount.value).floor
        end

        def max_loan_amount
          Money.new(LOAN_MAXIMUMS[@course_start][@residence])
        end
      end
    end
  end
end
