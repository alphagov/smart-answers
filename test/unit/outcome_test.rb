require_relative "../test_helper"

module SmartAnswer
  class OutcomeTest < ActiveSupport::TestCase
    setup do
      @outcome = Outcome.new(nil, "node-name")
    end

    context "#transition" do
      should "raise InvalidTransition exception so app responds with 404 Not Found" do
        assert_raises(InvalidTransition) do
          @outcome.transition
        end
      end
    end
  end
end
