module SmartAnswer
  class PrecalculationSampleFlow < Flow
    def define
      name 'precalculation-sample'
      status :draft

      value_question :how_much_wood_would_a_woodchuck_chuck_if_a_woodchuck_could_chuck_wood? do
        save_input_as :woodchuck_capacity

        next_node :how_many_woodchucks_do_you_have?
      end

      value_question :how_many_woodchucks_do_you_have? do
        save_input_as :number_of_woodchucks

        next_node :done
      end

      outcome :done do
        precalculate :amount_of_wood do
          woodchuck_capacity.to_i * number_of_woodchucks.to_i
        end

        precalculate :formatted_amount_of_wood do
          "#{amount_of_wood} " + (amount_of_wood == 1 ? "piece" : "pieces") + " of wood"
        end

        precalculate :formatted_capacity_of_woodchucks do
          "#{woodchuck_capacity} " + (woodchuck_capacity == 1 ? "piece" : "pieces") + " of wood"
        end

        precalculate :formatted_number_of_woodchucks do
          "#{number_of_woodchucks} " + (number_of_woodchucks == 1 ? "woodchuck" : "woodchucks")
        end
      end
    end
  end
end
