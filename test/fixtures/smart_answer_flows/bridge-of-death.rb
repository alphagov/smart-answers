module SmartAnswer
  class BridgeOfDeathFlow < Flow
    def define
      name 'bridge-of-death'
      status :draft

      value_question :what_is_your_name? do
        save_input_as :your_name
        next_node :what_is_your_quest?
      end

      multiple_choice :what_is_your_quest? do
        option :to_seek_the_holy_grail
        option :to_rescue_the_princess
        option :dunno

        next_node do |response|
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
        option blue: :done
        option blue_no_yellow: :auuuuuuuugh
        option red: :done
      end

      outcome :done
      outcome :auuuuuuuugh
    end
  end
end
