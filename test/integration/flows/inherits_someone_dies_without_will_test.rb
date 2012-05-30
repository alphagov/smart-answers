# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class InheritsSomeoneDiesWithoutWillTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'inherits-someone-dies-without-will'
  end

  should "ask if there is a living spouse or civil partner" do
    assert_current_node :is_there_a_living_spouse_or_civil_partner?
  end

  context "with a living spouse" do
    setup do
      add_response :yes
    end

    should "ask if the estate is worth more than 250k" do
      assert_current_node :is_the_estate_worth_more_than_250000?
    end

    should "partner receives everything if less than 250k" do
      add_response :no
      assert_current_node :partner_receives_all_of_the_estate
    end

    context "estate worth more than 250k" do
      setup do
        add_response :yes
      end

      should "ask if there are living children" do
        assert_current_node :are_there_living_children?
      end

      should "partner gets 250k, children get rest with living children" do
        add_response :yes
        assert_current_node :partner_receives_first_250000_children_receive_share_of_remainder
      end

      context "no living children" do
        setup do
          add_response :no
        end

        should "ask if there are living parents" do
          assert_current_node :are_there_living_parents?
        end

        should "partner gets 450k, parents and siblings get rest with living parents" do
          add_response :yes
          assert_current_node :partner_receives_first_450000_remainder_to_parents_or_siblings
        end

        context "no living parents" do
          setup do
            add_response :no
          end

          should "ask if there are any living siblings" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          should "partner gets 450k, siblings get rest with living siblings" do
            add_response :yes
            assert_current_node :partner_receives_first_450000_remainder_shared_equally_between_brothers_or_sisters
          end

          should "all go to partner with no living siblings" do
            add_response :no
            assert_current_node :partner_receives_all_of_the_estate
          end
        end # no living parents
      end # no living children
    end # estate 250k+
  end # with living spouse

  context "without a living spouse" do
    setup do
      add_response :no
    end

    should "ask if there are living children" do
      assert_current_node :are_there_living_children?
    end

    should "be shared between children if there are any" do
      add_response :yes
      assert_current_node :shared_equally_between_children
    end

    context "no living children" do
      setup do
        add_response :no
      end

      should "ask if there are living parents" do
        assert_current_node :are_there_living_parents?
      end

      should "be shared between parents if they are living" do
        add_response :yes
        assert_current_node :shared_equally_between_parents
      end

      context "no living parents" do
        setup do
          add_response :no
        end

        should "ask if there are any living siblings" do
          assert_current_node :are_there_any_brothers_or_sisters_living?
        end

        should "be shared between siblings if there are any living" do
          add_response :yes
          assert_current_node :shared_equally_between_brothers_or_sisters
        end

        context "with no living siblings" do
          setup do
            add_response :no
          end

          should "ask if there are any half siblings" do
            assert_current_node :are_there_half_blood_brothers_or_sisters?
          end

          should "be shared between half siblings if there are any" do
            add_response :yes
            assert_current_node :shared_equally_between_half_blood_brothers_sisters
          end

          context "with no half siblings" do
            setup do
              add_response :no
            end

            should "ask if there are any living grandparents" do
              assert_current_node :are_there_grandparents_living?
            end

            should "be shared between grandparents if any living" do
              add_response :yes
              assert_current_node :shared_equally_between_grandparents
            end

            context "with no grandparents living" do
              setup do
                add_response :no
              end

              should "ask if there are any living aunts or uncles" do
                assert_current_node :are_there_any_living_aunts_or_uncles?
              end

              should "be shared between aunts and uncles if there are any" do
                add_response :yes
                assert_current_node :shared_equally_between_aunts_or_uncles
              end

              context "with no living aunts or uncles" do
                setup do
                  add_response :no
                end

                should "ask if there are any living half aunts or uncles" do
                  assert_current_node :are_there_any_living_half_aunts_or_uncles?
                end

                should "be shared between half aunts and uncles if there are any" do
                  add_response :yes
                  assert_current_node :shared_equally_between_half_aunts_or_uncles
                end

                should "go to the crown if there are no half aunts or uncles" do
                  add_response :no
                  assert_current_node :everything_goes_to_crown
                end
              end # no living aunts or uncles
            end # no living grandparents
          end # no half siblings
        end # no living siblings
      end # no living parents
    end # no living children
  end # no living spouse
end
