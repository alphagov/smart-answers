module SmartAnswer
  class CalculateYourRedundancyPayFlow < Flow
    def define
      name 'calculate-your-redundancy-pay'

      status :published
      satisfies_need "100135"

      use_shared_logic "redundancy_pay"
    end
  end
end
