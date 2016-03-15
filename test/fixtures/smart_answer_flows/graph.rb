module SmartAnswer
  class GraphFlow < Flow
    def define
      name 'graph'
      status :draft

      multiple_choice :q1? do
        option :yes
        option :no

        next_node :q2?
      end

      multiple_choice :q2? do
        option :a
        option :b

        next_node(permitted: :auto) do |response|
          if response == 'a'
            outcome :done_a
          else
            question :q_with_interpolation?
          end
        end
      end

      multiple_choice :q_with_interpolation? do
        option :x
        option :y

        next_node :done_b
      end

      outcome :done_a
      outcome :done_b
    end
  end
end
