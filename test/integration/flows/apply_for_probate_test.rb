# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ApplyForProbateTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'apply-for-probate'
  end

  should "ask if there is a will" do
    assert_current_node :is_there_a_will?
  end

  context "answer no to will" do
    setup do
      add_response :no
    end

    should "display outcome for no will" do
      assert_current_node :no_will_outcome
    end
  end

  context "answer yes to will" do
    setup do
      add_response :yes
    end

    should "ask if the will names an executor" do
      assert_current_node :does_the_will_name_an_executor?
    end

    context "answer no to executor" do
      setup do
        add_response :no
      end

      should "display outcome for no executor" do
        assert_current_node :no_executor_outcome
      end
    end

    context "answer yes to executor" do
      setup do
        add_response :yes
      end

      should "ask if executor is willing to apply for probate" do
        assert_current_node :executor_willing_to_apply?
      end

      context "executor not willing to apply" do
        setup do
          add_response :no
        end

        should "display outcome for executor not willing to apply" do
          assert_current_node :executor_not_willing_outcome
        end
      end

      context "executor willing to apply" do
        setup do
          add_response :yes
        end

        should "ask whether solicitor will be used" do
          assert_current_node :use_a_solicitor?
        end

        context "use a solicitor" do
          setup do
            add_response :solicitor
          end

          should "display outcome for using a solicitor" do
            assert_current_node :use_a_solicitor_outcome
          end
        end

        context "apply on their own" do
          setup do
            add_response :myself
          end

          should "ask where the deceased lived" do
            assert_current_node :where_did_deceased_live?
          end

          context "england_or_wales" do
            setup do
              add_response :england_or_wales
            end

            should "ask if inheritance tax will be paid" do
              assert_current_node :inheritance_tax?
            end

            context "yes to inheritance tax" do
              setup do
                add_response :yes
              end

              should "ask about amount left for england and wales or scotland" do
                assert_current_node :amount_left_en_sco?
              end

              context "under £5000" do
                setup do
                  add_response :under_five_thousand
                end

                should "display inheritance tax and no fee for england and wales" do
                  assert_current_node :done_eng_wales
                  assert_phrase_list :application_info, [:eng_wales_inheritance_tax]
                  assert_phrase_list :fee_section, [:no_fee]
                end
              end

              context "£5000 and over" do
                setup do
                  add_response :five_thousand_or_more
                end

                should "display inheritance tax and fee to be paid for england and wales" do
                  assert_current_node :done_eng_wales
                  assert_phrase_list :application_info, [:eng_wales_inheritance_tax]
                  assert_phrase_list :fee_section, [:fee_info_eng_sco]
                end
              end
            end # yes to inheritance tax
          end # england or wales

          context "scotland" do
            setup do
              add_response :scotland
            end

            should "ask if inheritance tax will be paid" do
              assert_current_node :inheritance_tax?
            end

            context "no to inheritance tax" do
              setup do
                add_response :no
              end

              should "ask about amount left for england and wales or scotland" do
                assert_current_node :amount_left_en_sco?
              end

              context "under £5000" do
                setup do
                  add_response :under_five_thousand
                end

                should "display no inheritance tax and no fee for scotland" do
                  assert_current_node :done_scotland
                  assert_phrase_list :application_info, [:scotland_no_inheritance_tax]
                  assert_phrase_list :fee_section, [:no_fee]
                end
              end

              context "£5000 and over" do
                setup do
                  add_response :five_thousand_or_more
                end

                should "display no inheritance tax and fee to be paid for scotland" do
                  assert_current_node :done_scotland
                  assert_phrase_list :application_info, [:scotland_no_inheritance_tax]
                  assert_phrase_list :fee_section, [:fee_info_eng_sco]
                end
              end
            end #no inheritance tax
          end #scotland

          context "northern ireland" do
            setup do
              add_response :northern_ireland
            end

            should "ask if inheritance tax will be paid" do
              assert_current_node :inheritance_tax?
            end

            context "yes to inheritance tax" do
              setup do
                add_response :yes
              end

              should "ask which NI county" do
                assert_current_node :which_ni_county?
              end

              context "Antrim, Armagh, Down" do
                setup do
                  add_response :antrim_armagh_down
                end

                should "ask about left for northern ireland" do
                  assert_current_node :amount_left_ni?
                end

                context "under £10000" do
                  setup do
                    add_response :under_ten_thousand
                  end

                  should "display inheritance tax and no fee in antrim armagh and down in NI" do
                    assert_current_node :done_ni
                    assert_phrase_list :application_info, [:ni_inheritance_tax]
                    assert_phrase_list :where_to_apply, [:apply_in_antrim_armagh_down]
                    assert_phrase_list :fee_section, [:no_fee]
                  end
                end
              end
            end #ni, yes to inheritance tax, antrim etc

            context "no to inheritance tax" do
              setup do
                add_response :no
              end

              should "ask which NI county" do
                assert_current_node :which_ni_county?
              end

              context "Fermanagh, Londonderry, Tyrone" do
                setup do
                  add_response :fermanagh_londonderry_tyrone
                end

                should "ask about left for northern ireland" do
                  assert_current_node :amount_left_ni?
                end

                context "£10000 and over" do
                  setup do
                    add_response :ten_thousand_or_more
                  end

                  should "display no inheritance tax and fee to be paid in fermanagh, londonderry, tyrone in NI" do
                    assert_current_node :done_ni
                    assert_phrase_list :application_info, [:ni_no_inheritance_tax]
                    assert_phrase_list :where_to_apply, [:apply_in_fermanagh_londonderry_tyrone]
                    assert_phrase_list :fee_section, [:fee_info_ni]
                  end
                end
              end
            end #ni, no to inheritance tax, fermanagh etc
          end #NI
        end #apply on their own
      end
    end
  end
end


