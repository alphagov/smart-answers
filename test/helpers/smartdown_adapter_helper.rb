module SmartdownAdapterHepler
  class MockSmartdownState
    attr_reader :members
    def initialize(members)
      @members = members.stringify_keys
    end

    def get(key)
      members[key.to_s]
    end
  end

  def mock_smartdown_state(state_members)
    MockSmartdownState.new(state_members)
  end
end
