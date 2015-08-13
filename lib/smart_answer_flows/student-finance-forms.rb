module SmartAnswer
  class StudentFinanceFormsFlow < Flow
    def define
      name 'student-finance-forms'
      status :published
      satisfies_need "100982"

      multiple_choice :type_of_student? do
        option 'uk-full-time' => :form_needed_for_1?
        option 'uk-part-time' => :form_needed_for_2?
        option 'eu-full-time' => :what_year?
        option 'eu-part-time' => :what_year?

        save_input_as :type_of_student
      end

      use_outcome_templates
    end
  end
end
