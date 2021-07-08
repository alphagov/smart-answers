require "smart_answer_flows/shared/redundancy_pay_flow"

class CalculateYourRedundancyPayFlow < SmartAnswer::Flow
  def define
    content_id "d2786d90-20fa-467e-ac4a-ff51dcd01b4f"
    name "calculate-your-redundancy-pay"

    status :published

    append(RedundancyPayFlow.build)
  end
end
