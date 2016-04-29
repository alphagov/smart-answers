require_relative '../test_helper'

module SmartAnswer
  class OutcomeTest < ActiveSupport::TestCase
    setup do
      @outcome = Outcome.new(nil, 'node-name')
    end

    context '#transition' do
      should 'raise InvalidNode exception so app responds with 404 Not Found' do
        assert_raises(InvalidNode) do
          @outcome.transition
        end
      end
    end
  end
end
