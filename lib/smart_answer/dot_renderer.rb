require 'erubis'
require 'active_support/inflector'

module SmartAnswer
  def no_q(sym)
    sym.to_s.chomp('?')
  end

  def render_attrs(hash)
    values = hash.collect do |pair|
      key = pair.first
      value = pair.last
      value = %{"#{value}"} if key == 'label'
      "#{key}=#{value}"
    end.join(',')

    "[#{values}]"
  end

  def render_dot(tree, options = {})
    template = Erubis::Eruby.new(File.read(File.join(File.dirname(__FILE__), 'templates/digraph.erb')))
    template.result(binding)
  end

  module_function :render_dot, :no_q, :render_attrs
end