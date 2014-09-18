namespace :smartdown_generate_outcomes do

  desc "Convert a Smartdown package from transition status/name to published"
  task :employee_parental_leave => :environment do
    flow = SmartdownAdapter::Registry.instance.find("employee-parental-leave")

    def nested_outcomes(rules)
      rules.map { |rule|
        if rule.respond_to? :outcome
          rule.outcome
        else
          nested_outcomes(rule.children)
        end
      }
    end

    cover_node = flow.name.to_s

    start_node = flow.coversheet.elements.find { |e|
      e.is_a?(Smartdown::Model::Element::StartButton)
    }.start_node.to_s

    destination_nodes = flow.nodes.map(&:elements).flatten.select { |e|
      e.is_a?(Smartdown::Model::NextNodeRules)
    }.map(&:rules).map {
        |rules| nested_outcomes(rules)
    }.flatten.map(&:to_s).uniq

    all_nodes = ([cover_node, start_node] + flow.nodes.map(&:name))

    missing_nodes = destination_nodes - all_nodes

    missing_nodes.each do |node_name|
      node_filepath = File.join(smartdown_flow_path(flow.name), "outcomes", "#{node_name}.txt")
      _, *node_aspects = node_name.split('_')

      title = "\# #{node_name.humanize}"

      node_content = ([title] + node_aspects.map { |aspect|
        "SNIPPET{_#{aspect}}"}).join("\n\n")

      File.write(node_filepath, node_content)
    end
  end
end
