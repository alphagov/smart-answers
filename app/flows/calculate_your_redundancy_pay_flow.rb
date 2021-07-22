class CalculateYourRedundancyPayFlow < SmartAnswer::Flow
  def define
    content_id "d2786d90-20fa-467e-ac4a-ff51dcd01b4f"
    name "calculate-your-redundancy-pay"

    status :published

    append(RedundancyPayFlow.build)
  end
end
