class SessionResponseStore < ResponseStore
  def initialize(flow_name:, session:)
    @flow_name = flow_name
    super(responses: session)
  end

  def all
    @store[@flow_name] = {} if @store[@flow_name].nil?
    @store[@flow_name]
  end

  def clear
    @store.delete(@flow_name)
  end
end
