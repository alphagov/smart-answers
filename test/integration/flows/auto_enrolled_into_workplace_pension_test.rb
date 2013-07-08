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
        assert_current_node :how_many_people?
      end

      context "less than 30 people" do
        should "go to how old" do
          add_response 12 
          assert_current_node :how_old?
        end
      end

      context "biggest and smallest" do
        should "go to how_old on 30" do
          add_response 30 
          assert_current_node :how_old?
        end
        should "go to how_old on 9999999" do
          add_response 9999999
          assert_current_node :how_old?
        end
      end

      context "too small or too large" do
        should "break if 0" do
          add_response 0
          assert_current_node_is_error
        end
        should "break if 10m" do
          add_response 10000000
          assert_current_node_is_error
        end
        should "break if -100" do
          add_response -100
          assert_current_node_is_error
        end
        should "break if text" do
          add_response 'some text'
          assert_current_node_is_error
        end
      end

      
      context "go 100 employees" do
        setup do
          add_response 100
        end

        should "go to how_old?" do
          assert_current_node :how_old?
        end

        context "between 16 and 21" do
          setup do
            add_response :between_16_21
          end            
          should "ask for earnings" do
            assert_current_node :annual_earnings?
          end
          should "go to outcome not_enrolled_with_options on up_to_5k" do
            add_response :up_to_5k
            assert_current_node :not_enrolled_with_options
          end
          should "go to outcome not_enrolled_with_options on more_than_5k" do
            add_response :more_than_5k
            assert_current_node :not_enrolled_opt_in
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

          context "between 5k and 9k" do
            should "not be enrolled" do
              add_response :between_5k_9k
              assert_current_node :not_enrolled_opt_in
            end
          end

          context "income varies" do
            should "not be enrolled" do
              add_response :varies
              assert_current_node :not_enrolled_income_varies
            end
          end

          context "above 9k" do
            setup do
              add_response :more_than_9k
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

            context "carer" do
              should "not be enrolled" do
                add_response :carer
                assert_current_node :not_enrolled_carer
              end
            end

            context "foreign national" do
              should "be enrolled" do
                add_response :foreign_national
                assert_current_node :enrolled_foreign_national
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

  context "testing for agency when num_employees < 30" do
    setup do
      add_response 'yes'
      add_response 'no'
      add_response '25'
      add_response 'between_22_sp'
      add_response 'more_than_9k'
    end
    should "go to agency output with small company text" do
      add_response :agency
      assert_current_node :enrolled_agency
      assert_phrase_list :small_company, [:small_company_text]
    end
  end
  context "testing for several employers when num_employees < 30" do
    setup do
      add_response 'yes'
      add_response 'no'
      add_response '1'
      add_response 'between_22_sp'
      add_response 'more_than_9k'
    end
    should "go to several employers output with small company text" do
      add_response :several_employers
      assert_current_node :enrolled_several
      assert_phrase_list :small_company, [:small_company_text]
    end
  end
  context "testing for overseas employers when num_employees < 30" do
    setup do
      add_response 'yes'
      add_response 'no'
      add_response '29'
      add_response 'between_22_sp'
      add_response 'more_than_9k'
    end
    should "go to overseas employers output with small company text" do
      add_response :overseas_company
      assert_current_node :enrolled_overseas
      assert_phrase_list :small_company, [:small_company_text]
    end
  end
  context "testing for contract worker when num_employees < 30" do
    setup do
      add_response 'yes'
      add_response 'no'
      add_response '27'
      add_response 'between_22_sp'
      add_response 'more_than_9k'
    end
    should "go to contract worker output with small company text" do
      add_response :contract
      assert_current_node :enrolled_contract
      assert_phrase_list :small_company, [:small_company_text]
    end
  end
  context "testing for 'none of the above' when num_employees < 30" do
    setup do
      add_response 'yes'
      add_response 'no'
      add_response '27'
      add_response 'between_22_sp'
      add_response 'more_than_9k'
    end
    should "go to enrolled output with small company text" do
      add_response :none
      assert_current_node :enrolled
      assert_phrase_list :small_company, [:small_company_text]
    end
  end


end
