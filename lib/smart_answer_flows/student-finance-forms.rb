module SmartAnswer
  class StudentFinanceFormsFlow < Flow
    def define
      name 'student-finance-forms'
      status :published
      satisfies_need "100982"

      use_outcome_templates
    end
  end
end
