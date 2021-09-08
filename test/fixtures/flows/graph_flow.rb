class GraphFlow < SmartAnswer::Flow
  def define
    name "graph"
    status :draft

    radio :q1? do
      option :yes
      option :no

      next_node do
        question :q2?
      end
    end

    checkbox_question :q2? do
      option :a
      option :b

      next_node do |response|
        if response.split(",").include?("a")
          outcome :done_a
        else
          question :q_with_interpolation?
        end
      end
    end

    radio :q_with_interpolation? do
      option :x
      option :y

      next_node do
        outcome :done_b
      end
    end

    outcome :done_a
    outcome :done_b
  end
end
