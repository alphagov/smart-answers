class ResponseStore
  def initialize(responses: {}, user_response_keys: [], additional_keys: [])
    @user_response_keys = user_response_keys
    @additional_keys = additional_keys
    @store = responses
  end

  def all
    @store
  end

  def add(key, value)
    all[key] = value
  end

  def get(key)
    all[key]
  end

  def clear
    @store = {}
  end

  def clear_user_responses
    @user_response_keys.each { |key| all.delete(key) }
  end

  def forwarding_responses
    all
  end
end
