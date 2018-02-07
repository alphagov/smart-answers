module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      attr_accessor :course_start, :household_income, :residence, :course_type, :dental_or_medical_course

      LOAN_MAXIMUMS = {
        "2017-2018" => {
          "at-home" => 7_097,
          "away-outside-london" => 8_430,
          "away-in-london" => 11_002
        }
      }.freeze
      REDUCED_MAINTENTANCE_LOAN_AMOUNTS = {
        "at-home" => 1744,
        "away-in-london" => 3263,
        "away-outside-london" => 2324
      }
      CHILD_CARE_GRANTS = {
        "2017-2018" => {
          "one-child" => 159.59,
          "more-than-one-child" => 273.60
        }
      }
      PARENTS_LEARNING_ALLOWANCE = {
        "2017-2018" => 1617
      }
      ADULT_DEPENDANT_ALLOWANCE = {
        "2017-2018" => 2834
      }
      TUITION_FEE_MAXIMUM = {
        "2017-2018" => {
          "full-time" => 9250,
          "part-time" => 6935
        }
      }
      LOAN_MINIMUMS = {
        "2017-2018" => {
          "at-home" => 3_124,
          "away-outside-london" => 3_928,
          "away-in-london" => 5_479
        }
      }.freeze
      INCOME_PENALTY_RATIO = {
        "2017-2018" => {
          "at-home" => 8.36,
          "away-outside-london" => 8.26,
          "away-in-london" => 8.12
        }
      }.freeze

      def initialize(params = {})
        @course_start = params[:course_start]
        @household_income = params[:household_income]
        @residence = params[:residence]
        @course_type = params[:course_type]
        @dental_or_medical_course = params[:dental_or_medical_course]
      end

      def reduced_maintenance_loan_for_healthcare
        REDUCED_MAINTENTANCE_LOAN_AMOUNTS[@residence]
      end

      def childcare_grant_one_child
        CHILD_CARE_GRANTS.fetch(@course_start).fetch("one-child")
      end

      def childcare_grant_more_than_one_child
        CHILD_CARE_GRANTS.fetch(@course_start).fetch("more-than-one-child")
      end

      def parent_learning_allowance
        PARENTS_LEARNING_ALLOWANCE.fetch(@course_start)
      end

      def adult_dependant_allowance
        ADULT_DEPENDANT_ALLOWANCE.fetch(@course_start)
      end

      def tuition_fee_maximum
        if @course_type == "uk-full-time" || @course_type == "eu-full-time"
          tuition_fee_maximum_full_time
        else
          tuition_fee_maximum_part_time
        end
      end

      def tuition_fee_maximum_full_time
        TUITION_FEE_MAXIMUM.fetch(@course_start).fetch("full-time")
      end

      def tuition_fee_maximum_part_time
        TUITION_FEE_MAXIMUM.fetch(@course_start).fetch("part-time")
      end

      def doctor_or_dentist?
        @dental_or_medical_course == "doctor-or-dentist"
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
