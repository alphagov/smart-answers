module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name 'flow-sample'
      satisfies_need 4242

      multiple_choice :hotter_or_colder? do
        option hotter: :hot
        option colder: :cold
      end

      outcome :hot
      outcome :cold
    end
  end
end
