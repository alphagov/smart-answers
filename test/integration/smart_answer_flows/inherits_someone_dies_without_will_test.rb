require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/inherits-someone-dies-without-will"

class InheritsSomeoneDiesWithoutWillTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::InheritsSomeoneDiesWithoutWillFlow
  end

  context "england-and-wales" do
    setup { add_response "england-and-wales" }

    context "partner" do
      setup { add_response "yes" }

      context "estate<=250k" do
        setup { add_response "no" }

        should "give outcome 1" do
          assert_current_node :outcome_1 # T20
          assert_phrase_list :next_step_links, [:wills_link]
        end
      end

      context "estate>250k" do
        setup { add_response "yes" }

        context "children" do
          setup { add_response "yes" }

          should "give outcome 20" do
            assert_current_node :outcome_20 # T21
            assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
          end
        end

        context "no-children" do
          setup { add_response "no" }

          should "give outcome 1" do
            assert_current_node :outcome_1
            assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
          end
        end
      end
    end

    context "no-partner" do
      setup { add_response "no" }

      context "children" do
        setup { add_response "yes" }

        should "give outcome 2" do
          assert_current_node :outcome_2 # T25
          assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
        end
      end

      context "no-children" do
        setup { add_response "no" }

        context "parents" do
          setup { add_response "yes" }

          should "give outcome 3" do
            assert_current_node :outcome_3 # T26
            assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
          end
        end

        context "no-parents" do
          setup { add_response "no" }

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 4" do
              assert_current_node :outcome_4 # T27
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "no-siblings" do
            setup { add_response "no" }

            context "half-siblings" do
              setup { add_response "yes" }

              should "give outcome 23" do
                assert_current_node :outcome_23 # T28
                assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
              end
            end

            context "no-half-siblings" do
              setup { add_response "no" }

              context "grandparents" do
                setup { add_response "yes" }

                should "give outcome 5" do
                  assert_current_node :outcome_5 # T29
                  assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                end
              end

              context "no-grandparents" do
                setup { add_response "no" }

                context "aunts-uncles" do
                  setup { add_response "yes" }

                  should "give outcome 6" do
                    assert_current_node :outcome_6 # T30
                    assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                  end
                end

                context "no-aunts-uncles" do
                  setup { add_response "no" }

                  context "half-aunts-uncles" do
                    setup { add_response "yes" }

                    should "give outcome 24" do
                      assert_current_node :outcome_24 # T31
                      assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                    end
                  end

                  context "no-half-aunts-uncles" do
                    setup { add_response "no" }

                    should "give outcome 25" do
                      assert_current_node :outcome_25 # T32
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  context "scotland" do
    setup { add_response "scotland" }

    context "partner" do
      setup { add_response "yes" }

      context "children" do
        setup { add_response "yes" }

        should "give outcome 40" do
          assert_current_node :outcome_40 # T40
          assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
        end
      end

      context "no-children" do
        setup { add_response "no" }

        context "no-parents" do
          setup { add_response "no" }

          context "no-siblings" do
            setup { add_response "no" }

            should "give outcome 1" do
              assert_current_node :outcome_1 # T41
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 41" do
              assert_current_node :outcome_41 # T42
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end
        end

        context "parents" do
          setup { add_response "yes" }

          context "no-siblings" do
            setup { add_response "no" }

            should "give outcome 42" do
              assert_current_node :outcome_42 # T43
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 43" do
              assert_current_node :outcome_43 # T44
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end
        end
      end
    end

    context "no-partner" do
      setup { add_response "no" }

      context "children" do
        setup { add_response "yes" }

        should "give outcome 2" do
          assert_current_node :outcome_2 # T46
          assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
        end
      end

      context "no-children" do
        setup { add_response "no" }

        context "parents" do
          setup { add_response "yes" }

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 44" do
              assert_current_node :outcome_44 # T48
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "no-siblings" do
            setup { add_response "no" }

            should "give outcome 3" do
              assert_current_node :outcome_3 # T47
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end
        end

        context "no-parents" do
          setup { add_response "no" }

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 4" do
              assert_current_node :outcome_4 # T45
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "no-siblings" do
            setup { add_response "no" }

            context "aunts-uncles" do
              setup { add_response "yes" }

              should "give outcome 6" do
                assert_current_node :outcome_6 # T49
                assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
              end
            end

            context "no-aunts-uncles" do
              setup { add_response "no" }

              context "grandparents" do
                setup { add_response "yes" }

                should "give outcome 5" do
                  assert_current_node :outcome_5 # T50
                  assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                end
              end

              context "no-grandparents" do
                setup { add_response "no" }

                context "great-aunts-uncles" do
                  setup { add_response "yes" }

                  should "give outcome 45" do
                    assert_current_node :outcome_45 # T51
                    assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                  end
                end

                context "no-great-aunts-uncles" do
                  setup { add_response "no" }

                  should "give outcome 46" do
                    assert_current_node :outcome_46 # T52
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  context "northern-ireland" do
    setup { add_response "northern-ireland" }

    context "partner" do
      setup { add_response "yes" }

      context "estate<=250k" do
        setup { add_response "no" }

        should "give outcome 60" do
          assert_current_node :outcome_60 # T60
          assert_phrase_list :next_step_links, [:wills_link]
        end
      end

      context "estate>250k" do
        setup { add_response "yes" }

        context "children" do
          setup { add_response "yes" }

          context "mulitple-children" do
            setup { add_response "yes" }

            should "give outcome 61" do
              assert_current_node :outcome_61 # T61
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "one-child" do
            setup { add_response "no" }

            should "give outcome 62" do
              assert_current_node :outcome_62 # T62
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end
        end

        context "no-children" do
          setup { add_response "no" }

          context "parents" do
            setup { add_response "yes" }

            should "give outcome 63" do
              assert_current_node :outcome_63 # T63
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "no-parents" do
            setup { add_response "no" }

            context "siblings" do
              setup { add_response "yes" }

              should "give outcome 64" do
                assert_current_node :outcome_64 # T64
                assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
              end
            end

            context "no-siblings" do
              setup { add_response "no" }

              should "give outcome 65" do
                assert_current_node :outcome_65 # T65
                assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
              end
            end
          end
        end
      end
    end

    context "no-partner" do
      setup { add_response "no" }

      context "children" do
        setup { add_response "yes" }

        should "give outcome 66" do
          assert_current_node :outcome_66 # T66
          assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
        end
      end

      context "no-children" do
        setup { add_response "no" }

        context "parents" do
          setup { add_response "yes" }

          should "give outcome 3" do
            assert_current_node :outcome_3 # T67
            assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
          end
        end

        context "no-parents" do
          setup { add_response "no" }

          context "siblings" do
            setup { add_response "yes" }

            should "give outcome 4" do
              assert_current_node :outcome_4 # T68
              assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
            end
          end

          context "no-siblings" do
            setup { add_response "no" }

            context "grandparents" do
              setup { add_response "yes" }

              should "give outcome 5" do
                assert_current_node :outcome_5 # T70
                assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
              end
            end

            context "no-grandparents" do
              setup { add_response "no" }

              context "aunts-uncles" do
                setup { add_response "yes" }

                should "give outcome 6" do
                  assert_current_node :outcome_6 # T69
                  assert_phrase_list :next_step_links, [:wills_link, :inheritance_link]
                end
              end

              context "no-aunts-uncles" do
                setup { add_response "no" }

                should "give outcome 67" do
                  assert_current_node :outcome_67 # T71
                end
              end
            end
          end
        end
      end
    end
  end
end
