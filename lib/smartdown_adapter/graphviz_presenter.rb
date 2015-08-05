module SmartdownAdapter
  class GraphvizPresenter < SmartdownAdapter::GraphPresenter
    def initialize(name)
      @name = name
      @flow = SmartdownAdapter::Registry.instance.find(name)
    end

    def to_gv
      [
          "digraph MyFlow {",
          '',
          '## LABELS',
          '',
          label_lines,
          '',
          '## EDGES',
          '',
          edge_lines,
          metadata_lines,
          "}"
      ].flatten.join("\n")
    end

    def label_lines
      labels.map do |name, label|
        attrs = {
            label: escape(label),
            shape: "box"
        }
        if is_first?(name)
          attrs.merge!(
            color: "gold1",
            style: "filled"
          )
        elsif is_outcome?(name)
          attrs.merge!(
            color: "aquamarine",
            style: "filled"
          )
        end
        attribute_clause = attrs.map {|k, v| "#{k}=\"#{v}\""}.join(' ')
        %{#{normalize_name(name)} [#{attribute_clause}]}
      end
    end

    def is_first?(node_name)
      @flow.question_pages.first.name == node_name
    end

    def is_outcome?(node_name)
      @flow.outcomes.map(&:name).include?(node_name)
    end

    def edge_lines
      adjacency_list.map do |name, exits|
        exits.map do |nextnode, label|
          next unless nextnode
          %{#{normalize_name(name)}->#{normalize_name(nextnode)} [label="#{label}"];}
        end
      end.flatten
    end

    def metadata_lines
      [
          'overlap=false;',
          'splines=true;',
          %{label="#{escape(@name)}";},
          'fontsize=12;'
      ]
    end

    def escape(label)
      map = {
          "\n" => '\n',
          "[" => '\[',
          "]" => '\]',
          '"' => '\''
      }
      label.to_s.gsub(%r{[\n\[\]"]}, map)
    end

    def normalize_name(name)
      name.to_s.gsub(/[^a-zA-Z0-9_]/, "")
    end
  end
end
