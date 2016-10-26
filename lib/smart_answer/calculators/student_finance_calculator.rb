module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      attr_accessor :course_start, :household_income, :residence, :course_type
      
      LOAN_MAXIMUMS = {
        "2016-2017" => {
          "at-home" => 6_904,
          "away-outside-london" => 8_200,
          "away-in-london" => 10_702
        }
      }.freeze

      REDUCED_MAINTENTANCE_LOAN_AMOUNTS = {
        "at-home" => 1744,
        "away-in-london" => 3263,
        "away-outside-london" => 2324
      }

      delegate :maintenance_loan_amount, :maintenance_grant_amount, to: :strategy

      def initialize(params = {})
        @course_start = params[:course_start]
        @household_income = params[:household_income]
        @residence = params[:residence]
        @course_type = params[:course_type]
      end

      def reduced_maintenance_loan_for_healthcare
        REDUCED_MAINTENTANCE_LOAN_AMOUNTS[@residence]
      end

    private

      def strategy
        @strategy ||= Strategy.new(
          course_start: @course_start,
          household_income: @household_income,
          residence: @residence
        )
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
    end
  end
end
