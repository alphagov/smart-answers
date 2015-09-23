class NodePresenter
  extend Forwardable
  delegate [:outcome?] => :@node

  def initialize(i18n_prefix, node, state = nil)
    @i18n_prefix = i18n_prefix
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end
end
