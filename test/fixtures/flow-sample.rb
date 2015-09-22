module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name 'flow-sample'
      satisfies_need 4242

      multiple_choice :hotter_or_colder? do
        option hotter: :hot
        option colder: :frozen?
      end

      multiple_choice :frozen? do
        option yes: :frozen
        option no: :cold
      end

      outcome :hot
      outcome :cold
      outcome :frozen
    end
  end
end
