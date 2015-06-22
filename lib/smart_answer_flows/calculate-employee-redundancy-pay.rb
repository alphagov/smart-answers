module SmartAnswer
  class CalculateEmployeeRedundancyPayFlow < Flow
    def define
      name 'calculate-employee-redundancy-pay'

      status :published
      satisfies_need "100138"

      use_shared_logic "redundancy_pay"
    end
  end
end
