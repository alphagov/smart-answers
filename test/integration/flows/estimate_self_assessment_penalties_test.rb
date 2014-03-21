require_relative "../../test_helper"
require_relative "flow_test_helper"

TEST_CALCULATOR_DATES = {
  :online_filing_deadline => {
    :"2010-11" => Date.new(2012, 1, 31),
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  :offline_filing_deadline => {
    :"2010-11" => Date.new(2011, 10, 31),
    :"2011-12" => Date.new(2012, 10, 31),
    :"2012-13" => Date.new(2013, 10, 31)
  },
  :payment_deadline => {
    :"2010-11" => Date.new(2012, 1, 31),
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  
  #to be removed
  # :penalty1date => {
  #   :"2010-11" => Date.new(2012, 3, 2),
  #   :"2011-12" => Date.new(2013, 3, 2),
  #   :"2012-13" => Date.new(2014, 3, 2)
  # },
  # :penalty2date => {
  #   :"2010-11" => Date.new(2012, 8, 2),
  #   :"2011-12" => Date.new(2013, 8, 2),
  #   :"2012-13" => Date.new(2014, 8, 2)
  # },
  # :penalty3date => {
  #   :"2010-11" => Date.new(2013, 2, 2),
  #   :"2011-12" => Date.new(2014, 2, 2),
  #   :"2012-13" => Date.new(2015, 2, 2)
  # }
}
class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "estimate-self-assessment-penalties"
  end

  should "ask which year you want to estimate" do
    assert_current_node :which_year?
  end

  context "2012-13 entered" do
    setup do
      add_response :"2012-13"
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
      
      context "a date before filing deadline" do
        setup do
          add_response "2013-10-10"
        end
        should "ask when bill was paid" do
          assert_current_node :when_paid?
        end

        context "paid on time" do
          setup do
            add_response "2013-10-11"
          end

          should "show filed and paid on time outcome" do
            assert_current_node :filed_and_paid_on_time
          end
        end #end testing paid on time

        context "paid late less than 3 months after" do
          setup do
            add_response "2014-03-03"
          end
          should "ask how much your tax bill is" do
            assert_current_node :how_much_tax?
          end

          context "bill entered" do
            setup do
              add_response "0.00"
            end
            should "show results" do
              assert_current_node :late
              assert_state_variable :late_filing_penalty, 100
              assert_state_variable :total_owed, 100
              assert_state_variable :interest, 0
              assert_state_variable :late_payment_penalty, 0
              assert_phrase_list :result_parts, [:result_part2_no_penalty]
            end
          end
        end #end testing paid late but less than 3 months after 
        
      end
    end
  end
  context "check phraselist for over 365 days delay" do
    setup do
      add_response :"2011-12"
      add_response :online
      add_response "2014-10-10"
      add_response "2015-03-03"
      add_response "1000.00"
    end

    should "show results" do
      assert_phrase_list :result_parts, [:result_part2_penalty, :result_part_one_year_late]
    end
  end
  
  context "online return, tax year 2012-13" do
    setup do
      add_response :"2011-12"
      add_response :online
    end
    should "ask when bill was paid" do
      assert_current_node :when_paid?
    end
#band 1
#100£ fine (band 1)
    context "check 100£ fine (band 1)" do
      setup do
        add_response ""
        add_response ""
        add_response "0.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []
      end
    end
#band 2 
#100£ fine + 10£ per day (max 90 days, testing 1 day)(band 2)
    context "check 100£ fine + 10£ per day (max 90 days, testing 1 day) (band 2)" do
      setup do
        add_response ""
        add_response ""
        add_response "0.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []
      end
    end
#band 2 
#100£ fine + 10£ per day(max 90 days, testing 91 days)(band 2)
    context "check 100£ fine + 10£ per day (max 90 days, testing 91 days)(band 2)" do
      setup do
        add_response ""
        add_response ""
        add_response "0.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []
      end
    end 
#band 3 case 1
#300£ fine + 1000£(previous fine)(band 3), taxdue <= 6002£
    context "300£ fine + 1000£(previous fine)(band 3), taxdue < 6002£" do
      setup do
        add_response ""
        add_response ""
        add_response "0.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []
      end
    end 
#band 3 case 2
#5% fine + 1000£(previous fine)(band 3), taxdue > 6002£
    context "5% fine + 1000£(previous fine)(band 3), taxdue > 6002£" do
      setup do
        add_response ""
        add_response ""
        add_response "10000.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []
      end
    end 
#band 4 case 1
#300£ fine + 1300£(previous fine)(band 4), taxdue <= 6002£
    context "300£ fine + 1300£(previous fine)(band 4), taxdue <= 6002£" do
      setup do
        add_response ""
        add_response ""
        add_response "0.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []    
      end
    end
#band 4 case 2
#10% fine + 1000£(previous fine)(band 4), taxdue > 6002£
    context "10% fine + 1000£(previous fine)(band 4), taxdue > 6002£" do
      setup do
        add_response ""
        add_response ""
        add_response "10000.00"
      end
      should "show results" do
        assert_phrase_list :result_parts, []    
        
        #test also interest
      end
    end  
  end
end


#original test

# class EstimateSelfAssessmentPenaltiesTest < ActiveSupport::TestCase
#   include FlowTestHelper

#   setup do
#     setup_for_testing_flow "estimate-self-assessment-penalties"
#   end

#   should "ask which year you want to estimate" do
#     assert_current_node :which_year?
#   end

#   context "2011-12 entered" do
#     setup do
#       add_response :"2011-12"
#     end

#     should "ask whether self assessment tax return was submitted online or on paper" do
#       assert_current_node :how_submitted?
#     end

#     context "online" do
#       setup do
#         add_response :online
#       end

#       should "ask when self assessment tax return was submitted" do
#         assert_current_node :when_submitted?
#       end

#       context "a date during tax year" do
#         setup do
#           add_response "2012-04-01"
#         end
#         # Error message removed
#         # should "return an error for filing during tax year" do
#         #   assert_current_node_is_error
#         # end
#       end

#       context "a date before filing deadline" do
#         setup do
#           add_response "2012-10-10"
#         end

#         should "ask when bill was paid" do
#           assert_current_node :when_paid?
#         end

#         context "paid on time" do
#           setup do
#             add_response "2012-05-02"
#             calc = mock()
#             SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
#                 with(
#                   submission_method: "online",
#                   filing_date: "2012-10-10",
#                   payment_date: "2012-05-02",
#                   dates: TEST_CALCULATOR_DATES, 
#                   tax_year: '2011-12'
#                 ).returns(calc)
#             calc.expects(:paid_on_time?).returns(true)
#           end

#           should "show filed and paid on time" do
#             assert_current_node :filed_and_paid_on_time
#           end
#         end

#         context "paid late" do
#           setup do
#             add_response "2013-03-03"
#             calc = mock()
#             SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
#                 with(
#                 submission_method: "online",
#                 filing_date: "2012-10-10",
#                 payment_date: "2013-03-03",
#                 dates: TEST_CALCULATOR_DATES, 
#                 tax_year: '2011-12'
#             ).returns(calc)
#             calc.expects(:paid_on_time?).returns(false)
#           end

#           should "ask how much your tax bill is" do
#             assert_current_node :how_much_tax?
#           end

#           context "bill entered" do
#             setup do
#               add_response "1000.00"
#               calc = mock()
#               SmartAnswer::Calculators::SelfAssessmentPenalties.expects(:new).
#                   with(
#                     submission_method: "online",
#                     filing_date: "2012-10-10",
#                     payment_date: "2013-03-03",
#                     estimated_bill: 1000.00,
#                     dates: TEST_CALCULATOR_DATES,
#                     tax_year: '2011-12'
#               ).returns(calc)
#               calc.expects(:late_filing_penalty).at_least_once.returns(0)
#               calc.expects(:total_owed_plus_filing_penalty).returns(1052)
#               calc.expects(:interest).returns(2.55)
#               calc.expects(:late_payment_penalty).at_least_once.returns(50)
#             end

#             should "show results" do
#               assert_current_node :late
#               assert_state_variable :late_filing_penalty, 0
#               assert_state_variable :total_owed, 1052
#               assert_state_variable :interest, 2.55
#               assert_state_variable :late_payment_penalty, 50
#               assert_phrase_list :result_parts, [:result_part2_penalty]
#             end
#           end
#         end
#         #new test for new phrase
#       end
#     end
#   end
#   context "check new phraselist for over 365 days delay" do
#     setup do
#       add_response :"2011-12"
#       add_response :online
#       add_response "2014-10-10"
#       add_response "2015-03-03"
#       add_response "1000.00"
#     end

#     should "show results" do
#       assert_phrase_list :result_parts, [:result_part2_penalty, :result_part_one_year_late]
#     end
#   end
# end