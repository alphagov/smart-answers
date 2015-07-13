module SmartAnswer
  class GraphFlow < Flow
    def define
      name 'graph'
      status :draft

      multiple_choice :q1? do
        option yes: :done
        option no: :done
      end

      outcome :done
    end
  end
end
