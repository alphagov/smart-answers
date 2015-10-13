module SmartAnswer
  class CustomErrorsSampleFlow < Flow
    def define
      name 'custom-errors-sample'
      status :draft

      value_question :how_many_things_do_you_own? do
        next_node(permitted: [:done]) do |response|
          raise SmartAnswer::InvalidResponse, :custom_error unless response.to_i > 0
          :done
        end
      end

      outcome :done
    end
  end
end
