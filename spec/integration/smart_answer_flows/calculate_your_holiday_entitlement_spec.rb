require_relative "../../../lib/smart_answer_flows/calculate-your-holiday-entitlement.rb"
require_relative "../../../test/integration/smart_answer_flows/flow_test_helper.rb"

RSpec.describe(SmartAnswer::CalculateYourHolidayEntitlementFlow) do
  include(FlowTestHelper)

  before do
    setup_for_testing_flow(SmartAnswer::CalculateYourHolidayEntitlementFlow)
  end

  let(:calculator_class) { SmartAnswer::Calculators::HolidayEntitlement }
  let(:calculator_instance) { calculator_class.new }
  let(:some_value) { "some value" }

  context "for days worked per week" do
    before do
      assert_current_node(:basis_of_calculation?)
      add_response("days-worked-per-week")
      assert_current_node(:calculation_period?)
    end

    valid_working_days_per_week = [1, 2, 3, 4, 5, 6, 7]
    invalid_working_days_per_week = [0, 8]

    context "when full leave year" do
      before do
        add_response("full-year")
      end

      context "with valid number of days worked per week" do
        valid_working_days_per_week.each do |working_days_per_week|
          it "calculates the outcome" do
            assert_current_node(:how_many_days_per_week?)
            add_response(working_days_per_week)
            expect(calculator_class).to receive(:new)
              .with(
                working_days_per_week: working_days_per_week,
                start_date: nil,
                leaving_date: nil,
                leave_year_start_date: nil
              )
              .and_return(calculator_instance)
            expect(calculator_instance).to receive(:formatted_full_time_part_time_days)
              .and_return(some_value)
            assert_current_node(:days_per_week_done)
            assert_state_variable(:holiday_entitlement_days, some_value)
          end
        end
      end

      context "with invalid number of days worked per week" do
        invalid_working_days_per_week.each do |working_days_per_week|
          it "raises an invalid response error" do
            assert_current_node(:how_many_days_per_week?)
            add_response(working_days_per_week)
            expect(calculator_class).to_not receive(:new)
            assert_current_node(:how_many_days_per_week?, error: SmartAnswer::InvalidResponse)
          end
        end
      end
    end

    context "when starting part-way through a leave year" do
      before do
        add_response("starting")
      end

      let(:start_date) { "2019-03-14" }
      let(:leave_year_start_date) { "2019-05-02" }

      context "with valid number of days worked per week" do
        valid_working_days_per_week.each do |working_days_per_week|
          it "calculates the outcome" do
            assert_current_node(:what_is_your_starting_date?)
            add_response(start_date)
            assert_current_node(:when_does_your_leave_year_start?)
            add_response(leave_year_start_date)
            assert_current_node(:how_many_days_per_week?)
            add_response(working_days_per_week)
            expect(calculator_class).to receive(:new)
              .with(
                working_days_per_week: working_days_per_week,
                start_date: Date.parse(start_date),
                leaving_date: nil,
                leave_year_start_date: Date.parse(leave_year_start_date)
              )
              .and_return(calculator_instance)
            expect(calculator_instance).to receive(:formatted_full_time_part_time_days)
              .and_return(some_value)
            assert_current_node(:days_per_week_done)
            assert_state_variable(:holiday_entitlement_days, some_value)
          end
        end
      end

      context "with invalid number of days worked per week" do
        invalid_working_days_per_week.each do |working_days_per_week|
          it "raises an invalid response error" do
            assert_current_node(:what_is_your_starting_date?)
            add_response(start_date)
            assert_current_node(:when_does_your_leave_year_start?)
            add_response(leave_year_start_date)
            assert_current_node(:how_many_days_per_week?)
            add_response(working_days_per_week)
            expect(calculator_class).to_not receive(:new)
            assert_current_node(:how_many_days_per_week?, error: SmartAnswer::InvalidResponse)
          end
        end
      end
    end
  end
end
