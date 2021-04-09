module ContentItemHelper
  module MethodMissingHelper
    OVERRIDES = {
      "calculator.services_payment_partial_name" => "pay_by_cash_only",
      "calculator.holiday_entitlement_days" => 10,
      "calculator.path_to_outcome" => %w[italy ceremony_country opposite_sex],
      "calculator.ceremony_country" => "italy",
    }.freeze

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, *_args, &_block)
      object = MethodMissingObject.new(method, blank_to_s: true, overrides: OVERRIDES)
      OVERRIDES.fetch(object.description) { object }
    end
    # rubocop:enable Style/MissingRespondToMissing
  end

  def extract_flow_content(flow, start_node)
    content = [start_node.body, start_node.post_body]

    content += flow.nodes.flat_map do |node|
      case node
      when SmartAnswer::Question::Base
        pres = QuestionPresenter.new(node, nil, nil, helpers: [MethodMissingHelper])
        [pres.title, pres.body, pres.hint]
      when SmartAnswer::Outcome
        pres = OutcomePresenter.new(node, nil, nil, helpers: [MethodMissingHelper])
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
end
