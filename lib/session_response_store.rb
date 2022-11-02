class SessionResponseStore < ResponseStore
  def initialize(flow_name:, session:, user_response_keys: [], additional_keys: [])
    @flow_name = flow_name
    super(responses: session,
          user_response_keys:,
          additional_keys:)
  end

  def all
    @store[@flow_name] = {} if @store[@flow_name].nil?
    @store[@flow_name]
  end

  def clear
    @store.delete(@flow_name)
  end

  def forwarding_responses
    {}
  end
end
