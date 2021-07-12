class CalculateEmployeeRedundancyPayFlow < SmartAnswer::Flow
  def define
    content_id "a5b52037-1712-4544-a3d1-a352ce8a8287"
    name "calculate-employee-redundancy-pay"

    status :published

    append(RedundancyPayFlow.build)
  end
end
