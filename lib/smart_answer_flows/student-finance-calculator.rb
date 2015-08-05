module SmartAnswer
  class StudentFinanceCalculatorFlow < Flow
    def define
      name 'student-finance-calculator'
      status :published
      satisfies_need "100133"

      max_maintainence_loan_amounts = {
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
      }

      #Q1
      multiple_choice :when_does_your_course_start? do
        option :"2014-2015"
        option :"2015-2016"

        save_input_as :start_date
        next_node :what_type_of_student_are_you?
      end

      #Q2
      multiple_choice :what_type_of_student_are_you? do
        option :"uk-full-time"
        option :"uk-part-time"
        option :"eu-full-time"
        option :"eu-part-time"

        save_input_as :course_type
        next_node :how_much_are_your_tuition_fees_per_year?
      end

      #Q3
      money_question :how_much_are_your_tuition_fees_per_year? do
        calculate :tuition_fee_amount do |response|
          if course_type == "uk-full-time" or course_type == 'eu-full-time'
            raise SmartAnswer::InvalidResponse if response > 9000
          else
            raise SmartAnswer::InvalidResponse if response > 6750
          end
          Money.new(response)
        end

        next_node do
          case course_type
          when 'uk-full-time'
            :where_will_you_live_while_studying?
          when 'uk-part-time'
            :do_any_of_the_following_apply_all_uk_students?
          when 'eu-full-time', 'eu-part-time'
            :outcome_eu_students
          end
        end
      end
      #Q4
      multiple_choice :where_will_you_live_while_studying? do
        option :'at-home'
        option :'away-outside-london'
        option :'away-in-london'

        calculate :max_maintenance_loan_amount do |response|
          begin
            Money.new(max_maintainence_loan_amounts[start_date][response].to_s)
          rescue
            raise SmartAnswer::InvalidResponse
          end
        end

        save_input_as :where_living
        next_node :whats_your_household_income?
      end

      #Q5
      money_question :whats_your_household_income? do
        calculate :maintenance_grant_amount do |response|
          household_income = response
          # 2015-16 rates are the same as 2014-15:
          # max of £3,387 for income up to £25,000 then,
          # £1 less than max for each whole £5.28 above £25000 up to £42,611
          # min grant is £50 for income = £42,620
          # no grant for  income above £42,620
          if household_income <= 25000
            Money.new('3387')
          else
            if household_income > 42620
              Money.new('0')
            else
              Money.new(3387 - ((household_income - 25000) / 5.28).floor)
            end
          end
        end

        # loan amount depends on maintenance grant amount and household income
        calculate :maintenance_loan_amount do |response|
          if response <= 42875
            # reduce maintenance loan by £0.5 for each £1 of maintenance grant
            Money.new ( max_maintenance_loan_amount - (maintenance_grant_amount.value / 2.0).floor)
          else
            # reduce maintenance loan by £1 for each full £9.90 of income above £42875 until loan reaches 65% of max, when no further reduction applies
            min_loan_amount = (0.65 * max_maintenance_loan_amount.value).floor # to match the reference table
            reduced_loan_amount = max_maintenance_loan_amount - ((response - 42875) / 9.59).floor
            if reduced_loan_amount > min_loan_amount
              Money.new (reduced_loan_amount)
            else
              Money.new (min_loan_amount)
            end
          end
        end

        next_node :do_any_of_the_following_apply_uk_full_time_students_only?
      end

      #Q6a uk full-time students
      checkbox_question :do_any_of_the_following_apply_uk_full_time_students_only? do
        option :"children-under-17"
        option :"dependant-adult"
        option :"has-disability"
        option :"low-income"
        option :no

        calculate :uk_ft_circumstances do |response|
          response.split(',')
        end

        next_node :what_course_are_you_studying?
      end

      #Q6b uk students
      checkbox_question :do_any_of_the_following_apply_all_uk_students? do
        option :"has-disability"
        option :"low-income"
        option :no

        calculate :all_uk_students_circumstances do |response|
          response.split(',')
        end

        next_node :what_course_are_you_studying?
      end

      #Q7
      multiple_choice :what_course_are_you_studying? do
        option :"teacher-training"
        option :"dental-medical-healthcare"
        option :"social-work"
        option :"none-of-the-above"

        save_input_as :course_studied

        next_node do
          case course_type
          when 'uk-full-time'
            :outcome_uk_full_time_students
          when 'uk-part-time'
            :outcome_uk_all_students
          else
            :outcome_eu_students
          end
        end
      end

      use_outcome_templates

      outcome :outcome_uk_full_time_students

      outcome :outcome_uk_all_students

      outcome :outcome_eu_students
    end
  end
end
