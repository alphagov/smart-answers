module SmartAnswer
  class BridgeOfDeathFlow < Flow
    def define
      name 'bridge-of-death'
      status :draft

      use_erb_templates_for_questions

      value_question :what_is_your_name? do
        save_input_as :your_name
        next_node :what_is_your_quest?
      end

      multiple_choice :what_is_your_quest? do
        option :to_seek_the_holy_grail
        option :to_rescue_the_princess
        option :dunno

        permitted_next_nodes = [
          :what_is_the_capital_of_assyria?,
          :what_is_your_favorite_colour?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if your_name =~ /robin/i and response == 'to_seek_the_holy_grail'
            :what_is_the_capital_of_assyria?
          else
            :what_is_your_favorite_colour?
          end
        end
      end

      value_question :what_is_the_capital_of_assyria? do
        save_input_as :capital_of_assyria
        next_node :auuuuuuuugh
      end

      multiple_choice :what_is_your_favorite_colour? do
        option :blue
        option :blue_no_yellow
        option :red

        permitted_next_nodes = [
          :auuuuuuuugh,
          :done
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'blue', 'red'
            :done
          when 'blue_no_yellow'
            :auuuuuuuugh
          end
        end
      end

      outcome :done
      outcome :auuuuuuuugh
    end
  end
end
