module SmartAnswer
  class GraphFlow < Flow
    def define
      name 'graph'
      status :draft

      use_erb_templates_for_questions

      multiple_choice :q1? do
        option :yes
        option :no

        next_node :q2?
      end

      multiple_choice :q2? do
        option :a
        option :b

        permitted_next_nodes = [:done_a, :q_with_interpolation?]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'a'
            :done_a
          else
            :q_with_interpolation?
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
