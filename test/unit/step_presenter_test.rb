require_relative "../test_helper"

class StepPresenterTest < ActiveSupport::TestCase
  def step(flow_name, query_parameters)
    flow = SmartAnswer::FlowRegistry.instance.find(flow_name)
    StepPresenter.new(flow, query_parameters).to_hash
  end

  def assert_output_schema_fields(reply)
    branch = ToolSchemaPresenter::OUTPUT_SCHEMA[:oneOf].find do |schema|
      schema[:properties][:status][:const] == reply[:status]
    end
    required = ToolSchemaPresenter::OUTPUT_SCHEMA[:required] + branch[:required]

    assert_equal required.sort, reply.keys.map(&:to_s).sort
  end

  context "every published flow" do
    setup do
      @flows = SmartAnswer::FlowRegistry.instance.flows.select { |flow| flow.status == :published }
    end

    should "return the first question for no answers" do
      @flows.each do |flow|
        reply = StepPresenter.new(flow, {}).to_hash

        assert_equal "question", reply[:status], flow.name
        assert_equal ToolSchemaPresenter.new(flow).answer_key(flow.questions.first.name), reply[:node]
        assert_output_schema_fields(reply)
      end
    end

    should "have distinct answer keys" do
      @flows.each do |flow|
        tool_schema = ToolSchemaPresenter.new(flow)
        keys = flow.questions.map { |question| tool_schema.answer_key(question.name) }

        assert_equal keys.uniq, keys, flow.name
      end
    end
  end

  context "additional commodity code" do
    should "return the outcome with the answers the route didn't use" do
      sucrose_keys = %w[how_much_sucrose_1_q how_much_sucrose_2_q how_much_sucrose_3_q how_much_sucrose_4_q]
      milk_protein_keys = %w[
        how_much_milk_protein_ab_q
        how_much_milk_protein_c_q
        how_much_milk_protein_d_q
        how_much_milk_protein_ef_q
        how_much_milk_protein_gh_q
      ]
      answers = { "how_much_starch_glucose_q" => "25", "how_much_milk_fat_q" => "0" }
        .merge(sucrose_keys.index_with("5"), milk_protein_keys.index_with("0"))

      reply = step("additional-commodity-code", answers)

      assert_equal "commodity_code_result", reply[:node]
      assert_equal (sucrose_keys - %w[how_much_sucrose_2_q]) + (milk_protein_keys - %w[how_much_milk_protein_ab_q]),
                   reply[:unused]
      assert_equal "/additional-commodity-code/y/25/5/0/0", reply[:url]
      assert_output_schema_fields(reply)
    end

    should "list a key that isn't a question name as unused" do
      reply = step("additional-commodity-code", "starch" => "25")

      assert_equal %w[starch], reply[:unused]
    end
  end

  context "calculate statutory sick pay" do
    setup do
      @answers = {
        "is_your_employee_getting_q" => "none",
        "employee_tell_within_limit_q" => "yes",
        "employee_work_different_days_q" => "no",
        "first_sick_day_q" => "2026-01-05",
        "last_sick_day_q" => "2026-01-20",
        "has_linked_sickness_q" => "no",
        "paid_at_least_8_weeks_q" => "eight_weeks_more",
        "how_often_pay_employee_pay_patterns_q" => "weekly",
      }
    end

    should "ask for the last payday before the sickness" do
      reply = step("calculate-statutory-sick-pay", @answers)

      assert_equal "last_payday_before_sickness_q", reply[:node]
      assert_match "5 January 2026", reply[:message]
      assert_equal({ type: "string", format: "date" }, reply[:requestedSchema][:properties]["last_payday_before_sickness_q"].except(:description))
      assert_nil reply[:error]
    end

    should "ask for the last payday before the offset date" do
      reply = step("calculate-statutory-sick-pay", @answers.merge("last_payday_before_sickness_q" => "2026-01-02"))

      assert_equal "last_payday_before_offset_q", reply[:node]
      assert_match "7 November 2025", reply[:message]
    end

    should "return the question with an error for an invalid answer" do
      reply = step("calculate-statutory-sick-pay", @answers.merge("last_payday_before_sickness_q" => "2026-01-09"))

      assert_equal "last_payday_before_sickness_q", reply[:node]
      assert_not_nil reply[:error]
      assert_output_schema_fields(reply)
    end

    should "return the outcome for a full set of answers" do
      reply = step(
        "calculate-statutory-sick-pay",
        @answers.merge(
          "last_payday_before_sickness_q" => "2026-01-02",
          "last_payday_before_offset_q" => "2025-10-31",
          "total_employee_earnings_q" => "4000",
          "usual_work_days_q" => "1,2,3,4,5",
        ),
      )

      assert_equal "entitled_to_sick_pay", reply[:node]
      assert_equal [], reply[:unused]
      assert_output_schema_fields(reply)
    end

    should "return the outcome for a sick period across April 2026" do
      reply = step(
        "calculate-statutory-sick-pay",
        @answers.slice("is_your_employee_getting_q", "employee_tell_within_limit_q", "employee_work_different_days_q")
          .merge("first_sick_day_q" => "2026-03-30", "last_sick_day_q" => "2026-04-20"),
      )

      assert_equal "sick_period_may_not_straddle_april_2026_rule_change", reply[:node]
    end
  end

  should "ask a question named from earlier answers in child benefit tax" do
    reply = step(
      "child-benefit-tax-calculator",
      "how_many_children_q" => "2",
      "which_tax_year_q" => "2025",
      "is_part_year_claim_q" => "yes",
      "how_many_children_part_year_q" => "2",
      "child_benefit_1_start_q" => "2025-06-01",
      "add_child_benefit_1_stop_q" => "no",
    )

    assert_equal "child_benefit_2_start_q", reply[:node]
  end

  context "an outcome over 6,000 characters" do
    setup do
      OutcomePresenter.any_instance.stubs(:body).returns("<p>#{'a' * 20_000}</p>")
      @reply = step("additional-commodity-code", "how_much_starch_glucose_q" => "25",
                                                 "how_much_sucrose_2_q" => "5",
                                                 "how_much_milk_fat_q" => "0",
                                                 "how_much_milk_protein_ab_q" => "0")
    end

    should "cut the body and mark it truncated" do
      assert_equal StepPresenter::BODY_LIMIT, @reply[:body].length
      assert @reply[:truncated]
    end

    should "serialise to under 8,000 characters" do
      assert_operator @reply.to_json.length, :<, 8_000
    end
  end
end
