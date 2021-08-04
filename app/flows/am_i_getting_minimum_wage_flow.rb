class AmIGettingMinimumWageFlow < SmartAnswer::Flow
  def define
    content_id "111e006d-2b22-4b1f-989a-56bb61355d68"
    name "am-i-getting-minimum-wage"
    status :published
    append MinimumWageFlow.build
  end
end
