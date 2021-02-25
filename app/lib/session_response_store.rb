class SessionResponseStore
  def initialize(flow_name:, session:)
    @flow_name = flow_name
    @session = session
  end

  def all
    response_hash
  end

  def add(key, value)
    response_hash[key] = value
  end

  def get(key)
    response_hash[key]
  end

  def clear
    @session.delete(@flow_name)
  end

private

  def response_hash
    @session[@flow_name] ||= {}
  end
end
