require_relative "../../test_helper"
require_relative "flow_test_helper"

TEST_CALCULATOR_DATES = {
  :online_filing_deadline => {
    :"2011-12" => Date.new(2012, 1, 31),
    :"2012-13" => Date.new(2013, 1, 31)
  },
  :offline_filing_deadline => {
    :"2011-12" => Date.new(2011, 10, 31),
    :"2012-13" => Date.new(2012, 10, 31)
  },
  :payment_deadline => Date.new(2012, 1, 31),
  :penalty1date => Date.new(2012, 3, 2),
  :penalty2date => Date.new(2012, 8, 2),
  :penalty3date => Date.new(2013, 2, 2)
}
class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "estimate-self-assessment-penalties"
  end

  should "ask which year you want to estimate" do
    assert_current_node :which_year?
  end

  context "2011-12 entered" do
    setup do
      add_response :"2011-12"
    end

    should "ask whether self assessment tax return was submitted online or on paper" do
      assert_current_node :how_submitted?
    end

    context "online" do
      setup do
        add_response :online
      end

      should "ask when self assessment tax return was submitted" do
        assert_current_node :when_submitted?
      end

      context "a date" do
        setup do
          add_response "2012-01-01"
        end

        should "ask when bill was paid" do
          assert_current_node :when_paid?
        end

        context "paid on time" do
          setup do
            add_response "2012-01-02"
            calc = mock()
            SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
                with(
                  submission_method: "online",
                  filing_date: "2012-01-01",
                  payment_date: "2012-01-02",
                  dates: TEST_CALCULATOR_DATES, 
                  tax_year: '2011-12'
                ).returns(calc)
            calc.expects(:paid_on_time?).returns(true)
          end

          should "show filed and paid on time" do
            assert_current_node :filed_and_paid_on_time
          end
        end

        context "paid late" do
          setup do
            add_response "2012-03-01"
            calc = mock()
            SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
                with(
                submission_method: "online",
                filing_date: "2012-01-01",
                payment_date: "2012-03-01",
                dates: TEST_CALCULATOR_DATES, 
                tax_year: '2011-12'
            ).returns(calc)
            calc.expects(:paid_on_time?).returns(false)
          end

          should "ask how much you tax bill is" do
            assert_current_node :how_much_tax?
          end

          context "bill entered" do
            setup do
              add_response "12.50"
              calc = mock()
              SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
                  with(
                    submission_method: "online",
                    filing_date: "2012-01-01",
                    payment_date: "2012-03-01",
                    estimated_bill: 12.5,
                    dates: TEST_CALCULATOR_DATES,
                    tax_year: '2011-12'
              ).returns(calc)
              calc.expects(:late_filing_penalty).at_least_once.returns(100)
              calc.expects(:total_owed).returns(200)
              calc.expects(:interest).returns(12.30)
              calc.expects(:late_payment_penalty).at_least_once.returns(100)
            end

            should "show results" do
              assert_current_node :late
              assert_state_variable :late_filing_penalty, 100
              assert_state_variable :total_owed, 200
              assert_state_variable :interest, 12.30
              assert_state_variable :late_payment_penalty, 100
            end
          end

        end
      end
    end

  end
end