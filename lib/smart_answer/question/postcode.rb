module SmartAnswer
  module Question
    class Postcode < Base
      def parse_input(raw_input)
        postcode = UKPostcode.new(raw_input)
        raise InvalidResponse, :error_postcode_invalid unless postcode.valid?
        raise InvalidResponse, :error_postcode_incomplete unless postcode.full?
        postcode.normalize
      end
    end
  end
end
