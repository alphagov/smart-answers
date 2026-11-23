require_relative "../test_helper"

class ToolSchemaPresenterTest < ActiveSupport::TestCase
  setup do
    flow = SmartAnswer::FlowRegistry.instance.find("calculate-statutory-sick-pay")
    @presenter = ToolSchemaPresenter.new(flow)
  end

  should "describe questions in the input schema" do
    properties = @presenter.input_schema.as_json["properties"]

    assert_equal(
      {
        "type" => "array",
        "items" => {
          "enum" => %w[
            statutory_maternity_pay
            maternity_allowance
            statutory_paternity_pay
            statutory_adoption_pay
            statutory_parental_bereavement_pay
            shared_parental_leave_and_pay
            none
          ],
        },
        "uniqueItems" => true,
        "description" => "Pick any that apply, or [\"none\"] on its own.",
      },
      properties["is_your_employee_getting_q"],
    )
    assert_equal({ "type" => "string", "enum" => %w[yes no] }, properties["employee_tell_within_limit_q"])
    assert_equal({ "type" => "string", "format" => "date" }, properties["first_sick_day_q"])
    assert_equal(
      { "type" => "string", "description" => "Amount in pounds, such as 4000 or 250.50." },
      properties["total_employee_earnings_q"],
    )
  end

  should "map answer keys back to node names" do
    assert_equal "first_sick_day_q", @presenter.answer_key(:first_sick_day?)
    assert_equal :first_sick_day?, @presenter.node_name("first_sick_day_q")
    assert_nil @presenter.node_name("first_sick_day")
  end
end
