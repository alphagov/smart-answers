module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name 'flow-sample'
      satisfies_need 4242
      content_id "f26e566e-2557-4921-b944-9373c32255f1"

      multiple_choice :hotter_or_colder? do
        option hotter: :hot
        option colder: :cold
      end

      outcome :hot
      outcome :cold
    end
  end
end
