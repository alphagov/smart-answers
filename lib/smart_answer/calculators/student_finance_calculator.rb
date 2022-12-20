module SmartAnswer
  module Calculators
    class StudentFinanceCalculator
      attr_accessor :course_start,
                    :household_income,
                    :residence,
                    :course_type,
                    :course_studied,
                    :part_time_credits,
                    :full_time_credits,
                    :doctor_or_dentist,
                    :uk_ft_circumstances,
                    :uk_all_circumstances,
                    :tuition_fee_amount

      LOAN_MAXIMUMS = {
        "2023-2024" => {
          "at-home" => 8_400,
          "away-outside-london" => 9_978,
          "away-in-london" => 13_002,
        },
        "2022-2023" => {
          "at-home" => 8_171,
          "away-outside-london" => 9_706,
          "away-in-london" => 12_667,
        },
      }.freeze

      REDUCED_MAINTENTANCE_LOAN_AMOUNTS = {
        "2023-2024" => {
          "at-home" => 1955,
          "away-in-london" => 3658,
          "away-outside-london" => 2605,
        },
        "2022-2023" => {
          "at-home" => 1902,
          "away-in-london" => 3558,
          "away-outside-london" => 2534,
        },
      }.freeze

      CHILD_CARE_GRANTS = {
        "2023-2024" => {
          "one-child" => 188.90,
          "more-than-one-child" => 323.85,
        },
        "2022-2023" => {
          "one-child" => 183.75,
          "more-than-one-child" => 315.03,
        },
      }.freeze

      CHILD_CARE_GRANTS_ONE_CHILD_HOUSEHOLD_INCOME = 19_549.79
      CHILD_CARE_GRANTS_MORE_THAN_ONE_CHILD_HOUSEHOLD_INCOME = 27_958.19

      PARENTS_LEARNING_ALLOWANCE = {
        "2023-2024" => 1_915,
        "2022-2023" => 1_863,
      }.freeze

      PARENTS_LEARNING_HOUSEHOLD_INCOME = 18_739.98

      ADULT_DEPENDANT_ALLOWANCE = {
        "2023-2024" => 3_354,
        "2022-2023" => 3_263,
      }.freeze

      ADULT_DEPENDANT_HOUSEHOLD_INCOME = 15_453.98

      TUITION_FEE_MAXIMUM = {
        "full-time" => 9_250,
        "part-time" => 6_935,
      }.freeze

      LOAN_MINIMUMS = {
        "2023-2024" => {
          "at-home" => 3_698,
          "away-outside-london" => 4_651,
          "away-in-london" => 6_485,
        },
        "2022-2023" => {
          "at-home" => 3_597,
          "away-outside-london" => 4_524,
          "away-in-london" => 6_308,
        },
      }.freeze

      INCOME_PENALTY_RATIO = {
        "2023-2024" => {
          "at-home" => 7.08,
          "away-outside-london" => 7.01,
          "away-in-london" => 6.89,
        },
        "2022-2023" => {
          "at-home" => 7.27,
          "away-outside-london" => 7.20,
          "away-in-london" => 7.08,
        },
      }.freeze

      def initialize(params = {})
        @course_start = params[:course_start]
        @household_income = params[:household_income]
        @residence = params[:residence]
        @course_type = params[:course_type]
        @part_time_credits = params[:part_time_credits]
        @full_time_credits = params[:full_time_credits]
        @doctor_or_dentist = params[:doctor_or_dentist]
        @uk_ft_circumstances = params.fetch(:uk_ft_circumstances, [])
      end

      def reduced_maintenance_loan_for_healthcare
        REDUCED_MAINTENTANCE_LOAN_AMOUNTS.fetch(@course_start).fetch(@residence)
      end

      def eligible_for_childcare_grant_one_child?
        uk_ft_circumstances.include?("children-under-17") && household_income <= CHILD_CARE_GRANTS_ONE_CHILD_HOUSEHOLD_INCOME
      end

      def eligible_for_childcare_grant_more_than_one_child?
        uk_ft_circumstances.include?("children-under-17") && household_income <= CHILD_CARE_GRANTS_MORE_THAN_ONE_CHILD_HOUSEHOLD_INCOME
      end

      def childcare_grant_one_child
        CHILD_CARE_GRANTS.fetch(@course_start).fetch("one-child")
      end

      def childcare_grant_more_than_one_child
        CHILD_CARE_GRANTS.fetch(@course_start).fetch("more-than-one-child")
      end

      def eligible_for_parent_learning_allowance?
        uk_ft_circumstances.include?("children-under-17") && household_income <= PARENTS_LEARNING_HOUSEHOLD_INCOME
      end

      def parent_learning_allowance
        PARENTS_LEARNING_ALLOWANCE.fetch(@course_start)
      end

      def eligible_for_adult_dependant_allowance?
        uk_ft_circumstances.include?("dependant-adult") && household_income <= ADULT_DEPENDANT_HOUSEHOLD_INCOME
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
        TUITION_FEE_MAXIMUM.fetch("full-time")
      end

      def tuition_fee_maximum_part_time
        TUITION_FEE_MAXIMUM.fetch("part-time")
      end

      def maintenance_grant_amount
        SmartAnswer::Money.new(0)
      end

      def maintenance_loan_amount
        reduced_amount = max_loan_amount - reduction_based_on_income
        SmartAnswer::Money.new([reduced_amount, min_loan_amount].max * loan_proportion)
      end

      def course_start_years
        year_matches = /(\d{4})-(\d{4})/.match(@course_start)
        [year_matches[1].to_i, year_matches[2].to_i]
      end

      def valid_tuition_fee_amount?
        tuition_fee_amount <= tuition_fee_maximum
      end

      def valid_credit_amount?
        part_time_credits.positive?
      end

      def valid_full_time_credit_amount?
        full_time_credits.positive? && full_time_credits >= part_time_credits
      end

      def ineligible_for_extra_grants?
        uk_all_circumstances.include?("no") && course_studied != "teacher-training" && course_studied != "social-work"
      end

      def loan_shortfall
        SmartAnswer::Money.new(max_loan_amount - maintenance_loan_amount.to_f)
      end

      def max_loan_amount
        LOAN_MAXIMUMS[@course_start][@residence]
      end

    private

      def min_loan_amount
        LOAN_MINIMUMS[@course_start][@residence]
      end

      def reduction_based_on_income
        return 0 if @household_income <= 25_000

        ratio = INCOME_PENALTY_RATIO[@course_start][@residence]
        ((@household_income - 25_000) / ratio).floor
      end

      def course_intensity
        100 * (part_time_credits.to_f / full_time_credits)
      end

      def loan_proportion
        return 1 if @course_type == "uk-full-time" || course_intensity == 100
        return 0.75 if course_intensity >= 75
        return 0.666 if course_intensity >= 66.6
        return 0.5 if course_intensity >= 50
        return 0.333 if course_intensity >= 33.3
        return 0.25 if course_intensity >= 25

        0
      end
    end
  end
end
