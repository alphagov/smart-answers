require 'rails/html/sanitizer'

module SmartdownAdapter
  class FlowRegistrationPresenter
    def initialize(flow)
      @flow = flow
    end

    def slug
      @flow.name
    end

    def need_id
      @flow.need_id
    end

    def title
      @flow.title
    end

    def paths
      ["/#{slug}.json"]
    end

    def prefixes
      ["/#{slug}"]
    end

    def description
      @flow.meta_description
    end

    def indexable_content
      node_text(coversheet)
    end

    def state
      'live'
    end

  private

    def coversheet
      @flow.state(false, []).current_node
    end

    def node_text(node)
      Rails::Html::FullSanitizer.new.sanitize(node_html(node))
    end

    def node_html(node)
      [node.body, node.post_body].join("\n")
    end
  end
end
