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
      # tbc
      # previously took title/body from all nodes - is that even useful?
    end

    def state
      'live'
    end
  end
end
