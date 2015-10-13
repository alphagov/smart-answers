module SmartAnswer
  class MissingTransitionFlow < Flow
    def define
      name 'missing-transition'
      status :draft

      multiple_choice :q1? do
        option :yes
        option :no

        next_node(permitted: [:done]) do
          :done
        end
      end

      outcome :done
    end
  end
end
