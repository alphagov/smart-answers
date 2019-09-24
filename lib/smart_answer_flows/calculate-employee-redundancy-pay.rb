require "smart_answer_flows/shared/redundancy_pay_flow"

module SmartAnswer
  class CalculateEmployeeRedundancyPayFlow < Flow
    def define
      start_page_content_id "a5b52037-1712-4544-a3d1-a352ce8a8287"
      flow_content_id "04cbc84c-ad73-4f49-b5a0-ba4906b37e3b"
      name "calculate-employee-redundancy-pay"

      status :published
      satisfies_need "100138"

      append(Shared::RedundancyPayFlow.build)
    end
  end
end
