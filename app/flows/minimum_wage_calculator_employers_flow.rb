class MinimumWageCalculatorEmployersFlow < SmartAnswer::Flow
  def define
    content_id "cc25f6ca-0553-4400-9dba-a43294fee84b"
    name "minimum-wage-calculator-employers"
    status :published
    append MinimumWageFlow.build
  end
end
