module SmartdownAdapter
  class GraphPresenter
    def initialize(name)
      @name = name
      @flow = Flow.new(name)
    end

    def labels
      Hash[@flow.nodes.map { |node| [node.name, graph_label_text(node)]}]
    end

    def adjacency_list
      @adjacency_list ||= begin
        adjacency_list = {}
        @flow.questions.each do |node|
          adjacency_list[node.name.to_s] = []
          node.next_nodes.each do |nextnode|
            nextnode.rules.each do |rule|
              if rule.is_a? Smartdown::Model::NestedRule
                rule.children.each do |nested_rule|
                  adjacency_list[node.name.to_s] << [nested_rule.outcome.to_s, "TODO some rules"]
                end
              else
                adjacency_list[node.name.to_s] << [rule.outcome.to_s, "TODO some rules"]
              end
            end
          end
        end
        @flow.outcomes.each do |node|
          adjacency_list[node.name.to_s] = []
        end
        adjacency_list
      end
    end

    def visualisable?
      @flow.questions.all? do |node|
        node.permitted_next_nodes.any?
      end
    end

    def to_hash
      {
          labels: labels,
          adjacencyList: adjacency_list
      }
    end

    private
    def graph_label_text(node)
      text = node.class.to_s.split("::").last + "\n-\n"
      case node
        when SmartdownAdapter::MultipleChoice
          text << word_wrap(node.title.to_s)
          text << "\n\n"
          text << node.options.map do |option|
            "( ) #{option}"
          end.join("\n")
        when SmartdownAdapter::Outcome
          candidate_texts = [
              node.title.to_s,
              node.name.to_s
          ]
          text << word_wrap(candidate_texts.find(&:present?))
        else
          text << "Unknown node type"
      end
      text
    end

    def word_wrap(text, line_width = 40)
      text.split("\n").collect! do |line|
        line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
      end * "\n"
    end

    def allow_missing_interpolations(&block)
      old = I18n.config.missing_interpolation_argument_handler
      I18n.config.missing_interpolation_argument_handler = ->(key) { "((#{key}))" }
      block.call
    ensure
      I18n.config.missing_interpolation_argument_handler = old
    end

    def i18n_prefix(node)
      "flow.#{@flow.name}.#{node.name}"
    end

    def node_title(node)
      allow_missing_interpolations do
        I18n.translate!("#{i18n_prefix(node)}.title", {})
      end
    rescue I18n::MissingTranslationData
      ""
    end

    def node_body(node)
      allow_missing_interpolations do
        I18n.translate!("#{i18n_prefix(node)}.body", {})
      end
    rescue I18n::MissingTranslationData
      ""
    end

    def first_line_of_body(node)
      node_body(node).split("\n\n").first || ""
    end

    def translate_option(node, option)
      allow_missing_interpolations do
        begin
          I18n.translate!("flow.#{@flow.name}.options.#{option}")
        rescue I18n::MissingTranslationData
          I18n.translate("#{i18n_prefix(node)}.options.#{option}")
        end
      end
    end

    def presenter
      @presenter ||= FlowRegistrationPresenter.new(@flow)
    end
  end
end
