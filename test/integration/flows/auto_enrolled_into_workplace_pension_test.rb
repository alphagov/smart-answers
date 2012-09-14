# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class AutoEnrolledIntoWorkplacePensionTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'auto-enrolled-into-workplace-pension'
  end

  should "ask if you work in the UK" do
    assert_current_node :work_in_uk?
  end

  context "does not work in the UK" do
    should "not be enrolled in pension" do
      add_response :no
      assert_current_node :not_enrolled
    end
  end

  context "works in the UK" do
    setup do
      add_response :yes
    end

    should "ask if self employed" do
      assert_current_node :self_employed?
    end

    context "self employed" do
      should "not be enrolled in pension" do
        add_response :yes
        assert_current_node :not_enrolled_self_employed
      end
    end

    context "not self employed" do
      setup do
        add_response :no
      end

      should "ask if you are already in workplace pension" do
        assert_current_node :workplace_pension?
      end

      context "already in workplace pension" do
        should "say you will continue to pay" do
          add_response :yes
          assert_current_node :continue_to_pay
        end
      end

      context "not already in workplace pension" do
        setup do
          add_response :no
        end

        should "ask how old you will be" do
          assert_current_node :how_old?
        end

        context "between 16 and 21" do
          should "ask for earnings" do
            add_response :between_16_21
            assert_current_node :annual_earnings?
          end
        end

        context "state pension age" do
          setup do
            add_response :state_pension_age
          end

          should "ask for earnings" do
            assert_current_node :annual_earnings?
          end

          context "below 5k" do
            should "not be enrolled" do
              add_response :up_to_5k
              assert_current_node :not_enrolled_with_options
            end
          end

          context "above 5k" do
            should "not be enrolled" do
              add_response :more_than_5k
              assert_current_node :not_enrolled_opt_in
            end
          end
        end

        context "between 22 and state pension age" do
          setup do
            add_response :between_22_sp
          end

          should "ask for earings" do
            assert_current_node :annual_earnings2?
          end

          context "below 5k" do
            should "not be enrolled" do
              add_response :up_to_5k
              assert_current_node :not_enrolled_with_options
            end
          end

          context "between 5k and 8k" do
            should "not be enrolled" do
              add_response :between_5k_8k
              assert_current_node :not_enrolled_opt_in
            end
          end

          context "income varies" do
            should "not be enrolled" do
              add_response :varies
              assert_current_node :not_enrolled_income_varies
            end
          end

          context "above 8k" do
            setup do
              add_response :more_than_8k
            end

            should "ask if you are one of the following" do
              assert_current_node :one_of_the_following?
            end

            context "armed forces" do
              should "not be enrolled" do
                add_response :armed_forces
                assert_current_node :not_enrolled_mod
              end
            end

            context "agency" do
              should "be enrolled" do
                add_response :agency
                assert_current_node :enrolled_agency
              end
            end

            context "several employers" do
              should "be enrolled" do
                add_response :several_employers
                assert_current_node :enrolled_several
              end
            end

            context "overseas company" do
              should "be enrolled" do
                add_response :overseas_company
                assert_current_node :enrolled_overseas
              end
            end

            context "contract" do
              should "be enrolled" do
                add_response :contract
                assert_current_node :enrolled_contract
              end
            end

            context "office holder" do
              should "not be enrolled" do
                add_response :office_holder
                assert_current_node :not_enrolled_office
              end
            end

            context "none of the above" do
              should "be enrolled" do
                add_response :none
                assert_current_node :enrolled
              end
            end
          end
        end
      end
    end
  end
end