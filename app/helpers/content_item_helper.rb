module ContentItemHelper
  module MethodMissingHelper
    OVERRIDES = {
      "calculator.services_payment_partial_name" => "pay_by_cash_only",
      "calculator.holiday_entitlement_days" => 10,
      "calculator.path_to_outcome" => %w[italy ceremony_country opposite_sex],
      "calculator.ceremony_country" => "italy",
      "calculator.tuition_fee_maximum_full_time" => 0,
      "calculator.tuition_fee_maximum_part_time" => 0,
      "calculator.tuition_fee_amount" => 0,
      "calculator.maintenance_loan_amount" => 0,
      "calculator.max_loan_amount" => 0,
      "calculator.loan_shortfall" => 0,
      "calculator.childcare_grant_one_child" => 0,
      "calculator.childcare_grant_more_than_one_child" => 0,
      "calculator.parent_learning_allowance" => 0,
      "calculator.adult_dependant_allowance" => 0,
      "calculator.reduced_maintenance_loan_for_healthcare" => 0,
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
