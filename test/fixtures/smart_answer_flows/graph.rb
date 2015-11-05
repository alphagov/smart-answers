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

        permitted_next_nodes = [:done_a, :done_b]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'a'
            :done_a
          else
            :done_b
          end
        end
      end

      outcome :done_a
      outcome :done_b
    end
  end
end
