require_relative "../../test_helper"
require_relative "flow_test_helper"

class RequestForFlexibleWorkingTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "request-for-flexible-working"
  end

  ## Q1
  should "ask if member of armed services" do
    assert_current_node :member_of_armed_services?
  end

  should "give no_right_to_apply on 'yes'" do
    add_response :yes
    assert_current_node :no_right_to_apply
  end

  context "answer no" do
    setup {add_response :no}

    ## Q2 
    should "ask if employee" do
      assert_current_node :are_you_employee?
    end

    should "give no_right_to_apply on 'no'" do
      add_response :no
      assert_current_node :no_right_to_apply
    end
    
    context "answer yes" do
      setup {add_response :yes}

      ## Q3
      should "ask if applied for flexible working" do 
        assert_current_node :applied_for_flexible_working?
      end

      should "give no_right_to_apply on 'yes'" do
        add_response :yes
        assert_current_node :no_right_to_apply
      end

      context "answer no" do
        setup {add_response :no}

        ## Q4
        should "ask about child care" do
          assert_current_node :caring_for_child?
        end

        context "not caring for child" do
          should "not be allowed to apply" do
            add_response :neither
            assert_current_node :no_right_to_apply
          end
        end

        context "caring for child" do
          setup do
            add_response :caring_for_child
          end
          
          ## Q5
          should "ask what the relationship is" do
            assert_current_node :relationship_with_child?
          end

          context "is parent or other" do
            setup {add_response :yes}
            
            ## Q6
            should "be allowed to apply" do
              assert_current_node :responsible_for_upbringing?
            end

            should "give right_to_apply outcome on 'yes" do
              add_response :yes
              assert_current_node :right_to_apply
            end
            should "give no_right_to_apply outcome on 'no" do
              add_response :no
              assert_current_node :no_right_to_apply
            end
          end

          context "is not parent or other" do
            should "not be allowd to apply" do
              add_response :no
              assert_current_node :no_right_to_apply
            end
          end
        end

        context "caring for adult" do
          setup do
            add_response :caring_for_adult
          end

          ## Q7
          should "ask what the relationship is" do
            assert_current_node :relationship_with_adult_group?
          end

          should "on 'none', not be allowed to apply" do
            add_response :none
            assert_current_node :no_right_to_apply
          end
          should "on 'partner', be allowed to apply" do
            add_response :partner
            assert_current_node :right_to_apply
          end

          should "on 'guardian', be allowed to apply" do
            add_response :guardian
            assert_current_node :right_to_apply
          end

          should "on 'other relationship', be allowed to apply" do
            add_response :other_relationship
            assert_current_node :right_to_apply
          end

          should "specify family relationship" do
            add_response :family_member
            assert_current_node :right_to_apply
          end

        end

        
      end
    end
  end



end