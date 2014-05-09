require 'parser/current'
require 'pry'

class FlowAuditor
  def initialize(filename)
    @filename = filename
    @stack = []
  end

  def audit
    parsed = Parser::CurrentRuby.parse_file(@filename)

    nodes = []
    walk(parsed) do |tree, stack|
      if node?(tree)
        q_type = tree.children.first.children[1]
        node_name = tree.children.first.children[2].children.first
        possible_next_nodes = []
        walk(tree) do |sub_tree|
          if invocation_with_block?([:next_node], sub_tree)
            possible_next_nodes = extract_possible_next_nodes(sub_tree.children[2])
          end
        end
        permitted_next_nodes = []
        walk(tree) do |sub_tree|
          if invocation_of_permitted_next_nodes?(sub_tree)
            permitted_next_nodes = sub_tree.children[2..-1].map {|c| c.respond_to?(:type) && c.type == :sym && c.children.first }.compact
          end
        end
        missing = possible_next_nodes - permitted_next_nodes
        if missing.any?
          puts tree.location.expression
          puts "  #{q_type}(#{node_name})"
          puts "  Missing: #{missing.join(', ')}"
          puts ""
          puts "permitted_next_nodes(:#{(possible_next_nodes).join(', :')})"
          puts ""
        end
        # nodes << {
        #   q_type: q_type,
        #   node_name: node_name,
        #   possible_next_nodes: possible_next_nodes,
        #   permitted_next_nodes: permitted_next_nodes,
        #   location: tree.location
        # }
        throw :stop_recursion
      end
    end
  end

private
  NODE_METHODS = [
    :multiple_choice,
    :country_select,
    :date_question,
    :optional_date,
    :value_question,
    :money_question,
    :salary_question,
    :checkbox_question,
    :outcome
  ]

  def node?(tree)
    invocation_with_block?(NODE_METHODS, tree)
  end

  def invocation_with_block?(methods, tree)
    tree.respond_to?(:type) &&
      tree.type == :block &&
      tree.children.first.respond_to?(:type) &&
      tree.children.first.type == :send &&
      tree.children.first.children.first== nil &&
      methods.include?(tree.children.first.children[1])
  end

  def walk(tree, stack = [], &block)
    if tree.respond_to?(:children)
      catch(:stop_recursion) do
        block.call(tree, stack)
        sub_stack = stack + [tree.type]
        tree.children.each {|c| walk(c, sub_stack, &block) }
      end
    else
      block.call(tree, stack)
    end
  end

  # def dump_next_nodes_with_blocks(parse_tree)
  #   return unless parse_tree.respond_to?(:type)

  #   if parse_tree.type == :block && is_next_node_invocation?(parse_tree.children.first)
  #     puts parse_tree.location.expression
  #     @possible_next_nodes = extract_possible_next_nodes(parse_tree.children[2])
  #   elsif invocation_of_permitted_next_nodes?(parse_tree)
  #     declared_next_nodes = parse_tree.children[2..-1].map {|c| c.respond_to?(:type) && c.type == :sym && c.children.first }.compact
  #     missing = @possible_next_nodes - declared_next_nodes
  #     puts "possible_next_nodes(:#{missing.join(', :')})" if missing.any?
  #     puts "\n"
  #   else
  #     parse_tree.children.each {|tree| dump_next_nodes_with_blocks(tree)}
  #   end
  # end

  def is_next_node_invocation?(tree)
    tree.type == :send && tree.children == [nil, :next_node]
  end

  def invocation_of_permitted_next_nodes?(tree)
    tree.respond_to?(:type) && tree.type == :send && tree.children[0..1] == [nil, :permitted_next_nodes]
  end

  def extract_possible_next_nodes(tree)
    if tree.nil?
      []
    elsif tree.type == :begin
      tree.children.map do |child|
        extract_possible_next_nodes(child)
      end.flatten
    elsif tree.type == :case
      tree.children[1..-1]
        .map do |child|
          if child.nil?
            []
          elsif child.type == :when
            extract_possible_next_nodes(child.children.last)
          else
            extract_possible_next_nodes(child)
          end
        end
        .flatten
    elsif tree.type == :if
      extract_possible_next_nodes(tree.children[1]) +
        extract_possible_next_nodes(tree.children[2])
    elsif tree.type == :sym
      [tree.children.first]
    else
      []
    end
  end
end
