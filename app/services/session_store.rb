class SessionStore
  attr_reader :flow_name, :current_node, :session

  def initialize(flow_name:, current_node:, session:)
    @flow_name = flow_name
    @current_node = current_node
    @session = session
  end

  def hash
    session[flow_name] ||= {}
  end

  def add_response(response)
    hash[current_node] = response
  end

  def clear
    session.delete(flow_name)
  end
end
