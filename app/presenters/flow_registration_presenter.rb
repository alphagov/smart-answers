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

  module MethodMissingHelper
    TO_S_OVERRIDES = {
      'calculator.services_payment_partial_name' => 'pay_by_cash_only'
    }

    def method_missing(method, *_args, &_block)
      MethodMissingObject.new(method, nil, true, TO_S_OVERRIDES)
    end
  end

  def indexable_content
    HTMLEntities.new.decode(
      @flow.nodes.inject([start_node.body]) { |acc, node|
        case node
        when SmartAnswer::Question::Base
          pres = QuestionPresenter.new(node, nil, helpers: [MethodMissingHelper])
          acc.concat([:title, :body, :hint].map { |method|
            pres.send(method)
          })
        when SmartAnswer::Outcome
          pres = OutcomePresenter.new(node, nil, helpers: [MethodMissingHelper])
          acc.concat([:title, :body].map { |method|
            pres.send(method)
          })
        end
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
