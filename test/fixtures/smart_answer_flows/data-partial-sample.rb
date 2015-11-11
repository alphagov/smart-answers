module SmartAnswer
  class DataPartialSampleFlow < Flow
    def define
      name 'data-partial-sample'
      status :draft

      multiple_choice :what_are_you_testing? do
        option :data_partial_with_scalar
        option :data_partial_with_array

        permitted_next_nodes = [
          :done_scalar,
          :done_array
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'data_partial_with_scalar'
            :done_scalar
          when 'data_partial_with_array'
            :done_array
          end
        end
      end

      outcome :done_scalar do
        precalculate :sample_data do
          {
            "address" => "444-446 Pulteney Street\r\nAdelaide\r\nSA 5000\r\nAdelaide",
            "phone" => "(+61) (0) 2 6270 8888",
          }
        end
      end
      outcome :done_array do
        precalculate :sample_data do
          [
            {
              "address" => "British High Commission\r\nConsular Section\r\nCommonwealth Avenue\r\nYarralumla\r\nACT 2600",
              "phone" => "(+61) (0) 2 6270 6666",
            },
            {
              "address" => "British High Commission\r\nWellington\r\n44 Hill Street\r\nWellington 6011\r\n\r\nMailing Address:\r\nP O Box 1812\r\nWellington 6140\r\nWellington",
              "phone" => "(+64) (0) 9 6270 1234",
            },
          ]
        end
      end
    end
  end
end
