# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class InheritsSomeoneDiesWithoutWillTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'inherits-someone-dies-without-will-v2'
  end

  should "ask where the deceased lived" do
    assert_current_node :where_did_the_deceased_live?
  end

  should "reject an invalid region" do
    add_response "mordor"

    assert_current_node :where_did_the_deceased_live?
    assert_current_node_is_error
  end

  context "for england and wales" do
    setup do
      add_response "england-and-wales"
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
          assert_current_node :partner_receives_first_250000_children_receive_half_of_remainder
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
  end # england and wales

  context "for scotland" do
    setup do
      add_response "scotland"
    end

    should "ask if there is a living spouse or civil partner" do
      assert_current_node :is_there_a_living_spouse_or_civil_partner?
    end

    context "with a living partner" do
      setup do
        add_response "yes"
      end

      should "ask if there are living children" do
        assert_current_node :are_there_living_children?
      end

      context "with living children" do
        setup do
          add_response "yes"
        end

        should "go to the partner up to £473,000 with children receiving two thirds of the estate" do
          assert_current_node :partner_receives_first_473000_children_receive_two_thirds_of_remainder
        end
      end # with living children

      context "without living children" do
        setup do
          add_response "no"
        end

        should "ask if there are living parents" do
          assert_current_node :are_there_living_parents?
        end

        context "with living parents" do
          setup do
            add_response "yes"
          end

          should "ask if there are living brothers or sisters" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          context "with living brothers or sisters" do
            setup do
              add_response "yes"
            end

            should "go to the partner up to £473,000 with the rest divided in two between parents and siblings" do
              assert_current_node :partner_receives_first_473000_remainder_split_between_parents_and_siblings
            end
          end # no living brothers or sisters

          context "without any living brothers or sisters" do
            setup do
              add_response "no"
            end

            should "go to the partner" do
              assert_current_node :partner_receives_first_473000_remainder_to_parents
            end
          end # no living brothers or sisters
        end # no living parents

        context "no living parents" do
          setup do
            add_response "no"
          end

          should "ask if there are living brothers or sisters" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          context "with living brothers or sisters" do
            setup do
              add_response "yes"
            end

            should "go to the partner up to £473,000 with the rest divided in two between parents and siblings" do
              assert_current_node :partner_receives_first_473000_remainder_to_siblings
            end
          end # living brothers and sisters

          context "without any living brothers or sisters" do
            setup do
              add_response "no"
            end

            should "go to the partner" do
              assert_current_node :partner_receives_all_of_the_estate
            end
          end # no living brothers or sisters
        end # no living parents
      end # no living children
    end # with living partner

    context "without a living partner" do
      setup do
        add_response "no"
      end

      should "ask if there are living children" do
        assert_current_node :are_there_living_children?
      end

      context "with living children" do
        setup do
          add_response "yes"
        end

        should "be shared equally between children" do
          assert_current_node :shared_equally_between_children
        end
      end # living children

      context "no living children" do
        setup do
          add_response "no"
        end

        should "ask if there are living parents" do
          assert_current_node :are_there_living_parents?
        end

        context "living parents" do
          setup do
            add_response "yes"
          end

          should "ask if there are living brothers or sisters" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          context "living brothers or sisters" do
            setup do
              add_response "yes"
            end

            should "be shared equally between parents and siblings" do
              assert_current_node :shared_equally_between_parents_and_siblings # A18
            end
          end # living brothers or sisters

          context "no living brothers or sisters" do
            setup do
              add_response "no"
            end

            should "be shared equally between the parents" do
              assert_current_node :shared_equally_between_parents
            end
          end # no living brothers or sisters
        end # living parents

        context "no living parents" do
          setup do
            add_response "no"
          end

          should "ask if there are living brothers or sisters" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          context "living brothers or sisters" do
            setup do
              add_response "yes"
            end

            should "be shared equally between parents and siblings" do
              assert_current_node :shared_equally_between_brothers_or_sisters # A18
            end
          end # living brothers or sisters

          context "no living brothers or sisters" do
            setup do
              add_response "no"
            end

            should "ask if there are any living aunts or uncles" do
              assert_current_node :are_there_any_living_aunts_or_uncles?
            end

            context "living aunts or uncles" do
              setup do
                add_response "yes"
              end

              should "be shared equally between aunts and uncles" do
                assert_current_node :shared_equally_between_aunts_or_uncles
              end
            end # living aunts or uncles

            context "no living aunts or uncles" do
              setup do
                add_response "no"
              end

              should "ask if there are any living grandparents" do
                assert_current_node :are_there_grandparents_living?
              end

              context "living grandparents" do
                setup do
                  add_response "yes"
                end

                should "be shared equally between the grandparents" do
                  assert_current_node :shared_equally_between_grandparents
                end
              end # living grandparents

              context "no living grandparents" do
                setup do
                  add_response "no"
                end

                should "ask if there are any great aunts or uncles" do
                  assert_current_node :are_there_any_living_great_aunts_or_uncles?
                end

                context "living great aunts or uncles" do
                  setup do
                    add_response "yes"
                  end

                  should "be shared equally between any great aunts or uncles" do
                    assert_current_node :shared_equally_between_great_aunts_or_uncles
                  end
                end # living great aunts or uncles

                context "no living great aunts or uncles" do
                  setup do
                    add_response "no"
                  end

                  should "go to the crown" do
                    assert_current_node :everything_goes_to_crown
                  end
                end
              end # no living grandparents
            end # no aunts or uncles
          end # no brothers or sisters
        end # no living parents

      end # no living children
    end # no living partner
  end # scotland

  context "for northern ireland" do
    setup do
      add_response "northern-ireland"
    end

    should "ask if there is a living spouse or civil partner" do
      assert_current_node :is_there_a_living_spouse_or_civil_partner?
    end

    context "with a living partner" do
      setup do
        add_response "yes"
      end

      should "ask if the estate is worth more than 250k" do
        assert_current_node :is_the_estate_worth_more_than_250000?
      end

      context "estate worth less than 250k" do
        setup do
          add_response "no"
        end

        should "go to the partner" do
          assert_current_node :partner_receives_all_of_the_estate
        end
      end # estate < 250k

      context "estate worth more than 250k" do
        setup do
          add_response "yes"
        end

        should "ask if there are any living children" do
          assert_current_node :are_there_living_children?
        end

        context "living children" do
          setup do
            add_response "yes"
          end

          should "ask if there is more than one child" do
            assert_current_node :more_than_one_child?
          end

          context "not more than one child" do
            setup do
              add_response "no"
            end

            should "go to the partner for the first 250k, with remainder split equally between partner and children" do
              assert_current_node :partner_receives_first_250000_children_receive_half_of_remainder
            end
          end # not more than one child

          context "more than one child" do
            setup do
              add_response "yes"
            end

            should "go to the partner for the first 450k, with children receiving two-thirds of remainder" do
              assert_current_node :partner_receives_first_450000_children_receive_two_thirds_of_remainder
            end
          end # more than one child
        end # living children

        context "no living children" do
          setup do
            add_response "no"
          end

          should "ask if there are living parents" do
            assert_current_node :are_there_living_parents?
          end

          context "living parents" do
            setup do
              add_response "yes"
            end

            should "go to the partner for the first 450k, with parents receiving half of remainder" do
              assert_current_node :partner_receives_first_450000_parents_receive_half_of_remainder
            end
          end # living parents

          context "no living parents" do
            setup do
              add_response "no"
            end

            should "ask if there are any living brothers or sisters" do
              assert_current_node :are_there_any_brothers_or_sisters_living?
            end

            context "living brothers or sisters" do
              setup do
                add_response "yes"
              end

              should "go to the partner for the first 450k, with siblings receiving half of remainder" do
                assert_current_node :partner_receives_first_450000_siblings_receive_half_of_remainder
              end
            end # living brothers or sisters

            context "no living brothers or sisters" do
              setup do
                add_response "no"
              end

              should "go to the partner" do
                assert_current_node :partner_receives_all_of_the_estate
              end
            end # no living brothers or sisters
          end # no living parents
        end # no living children
      end # estate > 250k
    end # living partner

    context "no living partner" do
      setup do
        add_response "no"
      end

      should "ask if there are any living children" do
        assert_current_node :are_there_living_children?
      end

      context "living children" do
        setup do
          add_response "yes"
        end

        should "be shared equally between children" do
          assert_current_node :shared_equally_between_children
        end
      end # living children

      context "no living children" do
        setup do
          add_response "no"
        end

        should "ask if there are any living parents" do
          assert_current_node :are_there_living_parents?
        end

        context "living parents" do
          setup do
            add_response "yes"
          end

          should "be shared equally between parents" do
            assert_current_node :shared_equally_between_parents
          end
        end # living parents

        context "no living parents" do
          setup do
            add_response "no"
          end

          should "ask if there are any living brothers or sisters" do
            assert_current_node :are_there_any_brothers_or_sisters_living?
          end

          context "living brothers or sisters" do
            setup do
              add_response "yes"
            end

            should "be shared equally between brothers and sisters" do
              assert_current_node :shared_equally_between_brothers_or_sisters
            end
          end # living brothers or sisters

          context "no living brothers or sisters" do
            setup do
              add_response "no"
            end

            should "ask if there are any living aunts or uncles" do
              assert_current_node :are_there_any_living_aunts_or_uncles?
            end

            context "living aunts or uncles" do
              setup do
                add_response "yes"
              end

              should "be shared equally between aunts or uncles" do
                assert_current_node :shared_equally_between_aunts_or_uncles
              end
            end # living aunts or uncles

            context "no living aunts or uncles" do
              setup do
                add_response "no"
              end

              should "ask if there are any living grandparents" do
                assert_current_node :are_there_grandparents_living?
              end

              context "living grandparents" do
                setup do
                  add_response "yes"
                end

                should "be shared equally between grandparents" do
                  assert_current_node :shared_equally_between_grandparents
                end
              end # living grandparents

              context "no living grandparents" do
                setup do
                  add_response "no"
                end

                should "go to next-of-kin or the crown" do
                  assert_current_node :everything_goes_to_next_of_kin_or_crown
                end
              end
            end # no living aunts or uncles
          end # no living brothers or sisters
        end # no living parents
      end # no living children
    end # no living partner
  end # northern ireland
end
