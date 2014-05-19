class GraphvizPresenter < GraphPresenter
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
      %Q{#{normalize_name(name)} [label="#{escape(label)}" shape=box]}
    end
  end

  def edge_lines
    adjacency_list.map do |name, exits|
      exits.map do |nextnode, predicate|
        next unless nextnode
        %Q{#{normalize_name(name)}->#{normalize_name(nextnode)} [label="#{''}"];}
      end
    end.flatten
  end

  def metadata_lines
    [
      'overlap=false;',
      'splines=true;',
      %Q{label="#{escape(presenter.title)}";},
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
