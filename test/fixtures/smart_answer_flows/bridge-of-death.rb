module SmartAnswer
  class BridgeOfDeathFlow < Flow
    def define
      name "bridge-of-death"
      status :draft

      value_question :what_is_your_name? do
        on_response do |response|
          self.your_name = response
        end

        next_node do
          question :what_is_your_quest?
        end
      end

      radio :what_is_your_quest? do
        option :to_seek_the_holy_grail
        option :to_rescue_the_princess
        option :dunno

        next_node do |response|
          if your_name =~ /robin/i && response == "to_seek_the_holy_grail"
            question :what_is_the_capital_of_assyria?
          else
            question :what_is_your_favorite_colour?
          end
        end
      end

      value_question :what_is_the_capital_of_assyria? do
        on_response do |response|
          self.capital_of_assyria = response
        end

        next_node do
          outcome :auuuuuuuugh
        end
      end

      radio :what_is_your_favorite_colour? do
        option :blue
        option :blue_no_yellow
        option :red

        next_node do |response|
          case response
          when "blue", "red"
            outcome :done
          when "blue_no_yellow"
            outcome :auuuuuuuugh
          end
        end
      end

      outcome :done
      outcome :auuuuuuuugh
    end
  end
end
