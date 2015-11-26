class FlowRegistrationPresenter

  def initialize(flow)
    @flow = flow
    @i18n_prefix = "flow.#{@flow.name}"
  end

  def slug
    @flow.name
  end

  def need_id
    @flow.need_id
  end

  def content_id
    @flow.content_id
  end

  def title
    start_node.title
  end

  def paths
    ["/#{@flow.name}.json"]
  end

  def prefixes
    ["/#{@flow.name}"]
  end

  def description
    start_node.meta_description
  end

  NODE_PRESENTER_METHODS = [:title, :body, :hint]

  module MethodMissingHelper
    def method_missing(method, *args, &block)
      MethodMissingObject.new(method, parent_method = nil, blank_to_s = true)
    end
  end

  def indexable_content
    HTMLEntities.new.decode(
      text = @flow.questions.inject([start_node.body]) { |acc, node|
        pres = QuestionPresenter.new(@i18n_prefix, node, nil, helpers: [MethodMissingHelper])
        acc.concat(NODE_PRESENTER_METHODS.map { |method|
          pres.send(method)
        })
      }.compact.join(" ").gsub(/(?:<[^>]+>|\s)+/, " ")
    )
  end

  def state
    'live'
  end

private

  def start_node
    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    StartNodePresenter.new(node)
  end
end
