module SmartAnswer
  module Question
    class Salary < Base
      def parse_input(raw_input)
        SmartAnswer::Salary.new(raw_input)
      end
    end
  end
end
