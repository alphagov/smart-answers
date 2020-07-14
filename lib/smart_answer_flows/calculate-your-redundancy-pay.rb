require "smart_answer_flows/shared/redundancy_pay_flow"

module SmartAnswer
  class CalculateYourRedundancyPayFlow < Flow
    def define
      start_page_content_id "d2786d90-20fa-467e-ac4a-ff51dcd01b4f"
      flow_content_id "3b45f914-07a3-468d-b257-efbd2d25a08c"
      name "calculate-your-redundancy-pay"

      status :published
      satisfies_need "0165fbcc-e7a1-4c42-b6fa-a459384086f1"

      append(Shared::RedundancyPayFlow.build)
    end
  end
end
