require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RecogniseATradeUnion < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'recognise-a-trade-union'
  end

  should "ask what you need to do" do
    assert_current_node :what_do_you_need_to_do?
  end

  context "recognise a trade union" do
    setup do
      add_response :recognise_a_trade_union
    end

    should "ask about voluntary recognition" do
      assert_current_node :do_you_want_to_recognise_the_union_voluntarily?
    end

    should "agree to recognise the union" do
      add_response :yes
      assert_current_node :you_agree_to_recognise_the_union
    end

    context "do not agree" do
      setup do
        add_response :no
      end

      should "ask how many employees there are" do
        assert_current_node :how_many_employees_do_you_have?
      end

      should "not be able to apply to statutory recognition" do
        add_response :fewer_than_21
        assert_current_node :the_union_cannot_apply_for_statutory_recognition
      end

      context "21 or more employees" do
        setup do
          add_response :"21_or_more"
        end

        should "ask if they have submitted an application" do
          assert_current_node :have_they_submitted_an_application?
        end

        should "not require any action" do
          add_response :yes
          assert_current_node :no_action_required
        end

        context "application not submitted" do
          setup do
            add_response :no
          end

          should "ask if CAC have accepted the application" do
            assert_current_node :have_cac_accepted_the_application?
          end

          should "not require you to recognise the union, although they can reapply" do
            add_response :rejected
            assert_current_node :you_do_not_have_to_recognise_the_union_can_reapply
          end

          context "CAC have accepted the application" do
            setup do
              add_response :accepted
            end

            should "ask if agreed on the bargaining unit" do
              assert_current_node :agreed_on_bargaining_unit?
            end

            context "agreed on the bargaining unit" do
              should "ask if CAC have ordered a ballot" do
                add_response :yes
                assert_current_node :has_the_cac_ordered_a_ballot?
              end
            end

            context "not agreed on the bargaining unit" do
              setup do
                add_response :no
              end

              should "ask if CAC have ordered a ballot" do
                assert_current_node :has_the_cac_ordered_a_ballot?
              end

              should "recognise the union if CAC have declared recognition" do
                add_response :declared_recognition
                assert_current_node :you_agree_to_recognise_the_union
              end

              context "ballot ordered" do
                setup do
                  add_response :ordered_ballot
                end

                should "ask if the majority support the union" do
                  assert_current_node :did_the_majority_support_the_union_in_the_ballot?
                end

                should "recognise the union" do
                  add_response :yes
                  assert_current_node :you_agree_to_recognise_the_union
                end

                should "not recognise the union and they cannot reapply within 3 years" do
                  add_response :no
                  assert_current_node :you_do_not_have_to_recognise_the_union_cannot_reapply
                end
              end

              should "recognise the union if CAC have declared recognition" do
                add_response :declared_recognition
                assert_current_node :you_agree_to_recognise_the_union
              end

              context "ballot ordered" do
                setup do
                  add_response :ordered_ballot
                end

                should "ask if the majority support the union" do
                  assert_current_node :did_the_majority_support_the_union_in_the_ballot?
                end

                should "recognise the union" do
                  add_response :yes
                  assert_current_node :you_agree_to_recognise_the_union
                end

                should "not recognise the union and they cannot reapply within 3 years" do
                  add_response :no
                  assert_current_node :you_do_not_have_to_recognise_the_union_cannot_reapply
                end
              end

            end
          end
        end
      end
    end
  end

  context "derecognise a trade union" do
    setup do
      add_response :derecoognise_a_trade_union
    end

    should "ask if it has been 3 years since gaining recognition" do
      assert_current_node :has_it_been_3_years_since_gaining_recognition?
    end

    should "not be able to seek derecognition" do
      add_response :no
      assert_current_node :you_cannot_seek_derecognition
    end

    context "is has been more than 3 years since recognition" do
      setup do
        add_response :yes
      end

      should "ask on what grounds you are seeking recognition" do
        assert_current_node :on_what_grounds_are_you_seeking_derecognition?
      end

      context "lack of support for bargaining" do
        setup do
          add_response :lack_of_support_for_bargaining
        end

        should "ask if the union agrees" do
          assert_current_node :does_the_union_agree_with_derecognition_lack_of_bargaining_support?
        end

        should "derecognise the union" do
          add_response :agree
          assert_current_node :the_union_is_derecognised_and_bargaining_ends
        end

        context "union does not agree" do
          setup do
            add_response :does_not_agree
          end

          should "ask if CAC will hold a ballot" do
            assert_current_node :will_the_cac_hold_a_ballot_lack_of_bargaining_support?
          end

          should "continue with the existing arrangements" do
            add_response :do_not_hold_a_ballot
            assert_current_node :you_must_continue_with_the_existing_bargaining_arrangements
          end

          context "hold a ballot" do
            setup do
              add_response :hold_a_ballot
            end

            should "ask what the CAS's decision on the ballot is" do
              assert_current_node :what_is_the_cacs_decision_on_the_ballot?
            end

            should "derecognise union" do
              add_response :end_collective_bargaining
              assert_current_node :the_union_is_derecognised_and_bargaining_ends
            end

            should "continue with existing bargaining arrangements" do
              add_response :continue_collective_bargaining
              assert_current_node :you_must_continue_with_the_existing_bargaining_arrangements
            end
          end
        end
      end

      context "falling union membership" do
        setup do
          add_response :falling_union_membership
        end

        should "ask if the union agrees" do
          assert_current_node :does_the_union_agree_with_derecognition_falling_union_membership?
        end

        should "derecognise the union" do
          add_response :agree
          assert_current_node :the_union_is_derecognised_and_bargaining_ends
        end

        context "union does not agree" do
          setup do
            add_response :does_not_agree
          end

          should "ask if CAC will hold a ballot" do
            assert_current_node :will_the_cac_hold_a_ballot_falling_union_membership?
          end

          should "continue with existing arrangements" do
            add_response :do_not_hold_a_ballot
            assert_current_node :you_must_continue_with_the_existing_bargaining_arrangements
          end

          context "hold a ballot" do
            setup do
              add_response :hold_a_ballot
            end

            should "ask what the CAS's decision on the ballot is" do
              assert_current_node :what_is_the_cacs_decision_on_the_ballot?
            end

            should "derecognise union" do
              add_response :end_collective_bargaining
              assert_current_node :the_union_is_derecognised_and_bargaining_ends
            end

            should "continue with existing bargaining arrangements" do
              add_response :continue_collective_bargaining
              assert_current_node :you_must_continue_with_the_existing_bargaining_arrangements
            end
          end
        end
      end

      context "reduced workforce" do
        setup do
          add_response :reduced_workforce
        end

        should "ask if you have sent notice" do
          assert_current_node :have_you_sent_notice?
        end

        context "has not sent notice" do
          should "write to union" do
            add_response :no
            assert_current_node :write_to_union
          end
        end

        context "has sent notice" do
          setup do
            add_response :yes
          end

          should "ask if CAS has decided your notice is valid" do
            assert_current_node :is_your_derecognition_valid?
          end

          should "not be able to seek derecognition" do
            add_response :not_valid
            assert_current_node :you_cannot_seek_derecognition
          end

          should "be derecognised" do
            add_response :valid
            assert_current_node :the_union_is_derecognised_and_bargaining_will_end
          end
        end
      end
    end
  end
end