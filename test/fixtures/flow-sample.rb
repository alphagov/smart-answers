module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name 'flow-sample'

      multiple_choice :hotter_or_colder? do
        option hotter: :hot
        option colder: :cold
      end

      outcome :hot
      outcome :cold
    end
  end
end
