class ResponseStore
  def initialize(responses:)
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
end
