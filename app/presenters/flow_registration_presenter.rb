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

  def start_page_content_id
    @flow.start_page_content_id
  end

  def flow_content_id
    @flow.flow_content_id
  end

  def title
    start_node.title
  end

  def description
    start_node.meta_description
  end

  def external_related_links
    @flow.external_related_links || []
  end

  def start_page_body
    start_node.body
  end

  def start_page_post_body
    start_node.post_body
  end

  def start_page_button_text
    start_node.start_button_text
  end

  module MethodMissingHelper
    OVERRIDES = {
      "calculator.services_payment_partial_name" => "pay_by_cash_only",
      "calculator.holiday_entitlement_days" => 10,
      "calculator.path_to_outcome" => %w(italy ceremony_country opposite_sex),
      "calculator.ceremony_country" => "italy",
    }.freeze

    # rubocop:disable Style/MethodMissingSuper
    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, *_args, &_block)
      object = MethodMissingObject.new(method, nil, true, OVERRIDES)
      OVERRIDES.fetch(object.description) { object }
    end
    # rubocop:enable Style/MethodMissingSuper
    # rubocop:enable Style/MissingRespondToMissing
  end

  def flows_content
    content = @flow.nodes.flat_map do |node|
      case node
      when SmartAnswer::Question::Base
        pres = QuestionPresenter.new(node, nil, helpers: [MethodMissingHelper])
        [pres.title, pres.body, pres.hint]
      when SmartAnswer::Outcome
        pres = OutcomePresenter.new(node, nil, helpers: [MethodMissingHelper])
        [pres.title, pres.body]
      end
    end

    content
      .compact
      .reject(&:blank?)
      .map do |html|
        HTMLEntities.new
          .decode(html)
          .gsub(/(?:<[^>]+>|\s)+/, " ")
          .strip
      end
  end

  def state
    "live"
  end

private

  def start_node
    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    StartNodePresenter.new(node)
  end
end
