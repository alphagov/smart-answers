module SmartAnswer
  class CalculateEmployeeRedundancyPayFlow < Flow
    def define
      content_id "a5b52037-1712-4544-a3d1-a352ce8a8287"
      name 'calculate-employee-redundancy-pay'

      status :published
      satisfies_need "100138"

      use_erb_templates_for_questions

      use_shared_logic "redundancy_pay"
    end
  end
end
