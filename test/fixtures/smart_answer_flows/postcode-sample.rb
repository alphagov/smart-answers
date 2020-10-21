module SmartAnswer
  class PostcodeSampleFlow < Flow
    def define
      name "postcode-sample"
      status :draft

      postcode_question :user_input? do
        on_response do |response|
          self.user_input = response
        end

        next_node do
          outcome :outcome
        end
      end

      outcome :outcome
    end
  end
end
