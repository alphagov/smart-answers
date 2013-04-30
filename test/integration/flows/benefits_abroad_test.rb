# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-abroad'
  end

  # Q1
  should "ask if you are going or are already abroad" do
    assert_current_node :going_or_already_abroad?
  end

  context "when currently abroad" do
    setup do
      add_response "going_abroad"
    end
    # Q2
    should "ask which benefit you want to claim" do
      assert_current_node :which_benefit?
    end
    context "answer JSA" do
      setup do
        add_response 'jsa'
      end
      # Q3
      should "ask which country you are moving to" do
        assert_current_node :which_country_are_you_moving_to_jsa?
      end
      context "answer a country within the EEA" do
        should "state JSA entitlement in the EEA" do
          add_response 'austria'
          assert_current_node :jsa_eea
        end
      end
      context "answer outside EEA" do
        should "state JSA entitlement outside the EEA" do
          add_response 'bosnia-and-herzegovina'
          assert_current_node :jsa_social_security
        end
      end
      context "answer India" do
        should "state you are not entitled to JSA" do
          add_response 'india'
          assert_current_node :jsa_not_entitled
        end
      end
    end # JSA
    context "answer pension" do
      should "give the pension outcome" do
        add_response 'pension'
        assert_current_node :pension_outcome
      end
    end # Pension
    context "answer winter fuel payments" do
      setup do
        add_response 'wfp'
      end
      # Q6
      should "ask which country you are moving to" do
      end
      context "answer Austria (EEA country)" do
        setup do
          add_response 'austria'
        end
        should "ask if you already qualify for WFP" do
          assert_current_node :qualify_for_wfp?
        end
        context "answer yes" do
          should "state WFP entitlement" do
            add_response 'yes'
            assert_current_node :wfp_outcome
          end
        end
        context "answer no" do
          should "state not entitled to WFP" do
            add_response 'no'
            assert_current_node :wfp_not_entitled
          end
        end
      end
      context "answer Australia (outside EEA)" do
        should "state not entitled to WFP" do
          add_response 'australia'
          assert_current_node :wfp_not_entitled
        end
      end
    end # Winter fuel payments
    context "answer maternity pay" do
      setup do
        add_response 'maternity_benefits'
      end
      should "ask which country you are moving to" do
        assert_current_node :which_country_are_you_moving_to_maternity?
      end
      context "answer austria (EEA country)" do
        setup do
          add_response 'austria'
        end
        should "ask if you will be working for a UK employer" do
          assert_current_node :working_for_a_uk_employer?
        end
        context "answer yes" do
          setup do
            add_response 'yes'
          end
          should "ask if you are eligible for SMP" do
            assert_current_node :eligible_for_maternity_pay?
          end
          context "answer yes" do
            should "state SMP entitlement" do
              add_response 'yes'
              assert_current_node :smp_outcome
            end
          end
          context "answer no" do
            should "state you cant get SMP but may be able to get maternity allowance" do
              add_response 'no'
              assert_current_node :smp_not_entitled
            end
          end # Entitled to SMP
        end # UK employer
        context "answer no" do
          should "state you're not entitled to SMP" do
            add_response 'no'
            assert_current_node :smp_not_entitled
          end
        end
      end # EEA country
      context "answer Croatia" do
        setup do
          add_response 'croatia'
        end
        should "ask if your employer is paying NI for you" do
          assert_current_node :employer_paying_ni?
        end
        context "answer yes" do
          should "ask of you are eligible for SMP" do
            add_response 'yes'
            assert_current_node :eligible_for_maternity_pay?
          end
        end
        context "answer no" do
          should "state you may be entitled to maternity allowance" do
            add_response 'no'
            assert_current_node :maternity_allowance
          end
        end
      end # Social security country
      context "answer Gambia, employer not paying NI" do
        should "state you are not entitled to SMP or maternity allowance" do
          add_response 'gambia'
          add_response 'no'
          assert_current_node :maternity_not_entitled
        end
      end # Gambia
    end # Maternity
    context "answer Child benefit" do
      setup do
        add_response 'child_benefits'
      end
      should "ask which country you are moving to" do
        assert_current_node :which_country_are_you_moving_to_cb?
      end
      context "answer Austria (EEA country)" do
        setup do
          add_response 'austria'
        end
        should "ask if your employer pays NI or you are already on benefits" do
          assert_current_node :do_either_of_the_following_apply?
        end
        context "answer yes" do
          should "state your entitlement" do
            add_response 'yes'
            assert_current_node :cb_outcome
          end
        end
        context "answer no" do
          should "state you are not entitled" do
            add_response 'no'
            assert_current_node :cb_not_entitled
          end
        end
      end # EEA country
      context "answer croatia" do
        should "state entitlement for former Yugoslavian countries" do
          add_response 'croatia'
          assert_current_node :cb_fy_social_security_outcome
        end
      end # Former Yugoslavia
      context "canada" do
        should "state entitlement for countries with social security agreements" do
          add_response 'canada'
          assert_current_node :cb_social_security_outcome
        end
      end # Social security
      context "answer Turkey" do
        should "state exceptions for Jamaica, Turkey and USA" do
          add_response 'turkey'
          assert_current_node :cb_jtu_not_entitled
        end
      end # Jamaica Turkey USA exceptions
      context "answer Australia" do
        should "state you are not entitled" do
          add_response 'australia'
          assert_current_node :cb_not_entitled
        end
      end # 'other' country
    end # Child benefit
    context "answer SSP" do
      setup do
        add_response 'ssp'
      end
      should "ask which country you are moving to" do
        assert_current_node :which_country_are_you_moving_to_ssp?
      end
      context "answer Austria (EEA country)" do
        setup do
          add_response 'austria'
        end
        should "ask if you are working for a UK employer" do
          assert_current_node :working_for_a_uk_employer_ssp?
        end
        context "answer yes" do
          should "state entitlement" do
            add_response 'yes'
            assert_current_node :ssp_outcome
          end
        end
        context "answer no" do
          should "state you are not entitled" do
            add_response 'no'
            assert_current_node :ssp_not_entitled
          end
        end
      end # EEA country
      context "answer Yemen" do
        setup do
          add_response 'yemen'
        end
        should "ask if your employer is paying NI" do
          assert_current_node :employer_paying_ni_ssp?
        end
        context "answer yes" do
          should "state entitlement" do
            add_response 'yes'
            assert_current_node :ssp_outcome
          end
        end
        context "answer no" do
          should "state you are not entitled" do
            add_response 'no'
            assert_current_node :ssp_not_entitled
          end
        end
      end # 'Other' country
    end # SSP
    context "answer tax credits" do
      setup do
        add_response 'tax_credits'
      end
      # Q16
      should "ask if you are eligible for tax credits" do
        assert_current_node :eligible_for_tax_credits?
      end
      context "answer yes" do
        setup do
          add_response 'yes'
        end
        should "ask if you one of the following" do
          assert_current_node :are_you_one_of_the_following?
        end
        context "answer crown servant" do
          should "state tax credits eligibility" do
            add_response 'crown_servant'
            assert_current_node :tax_credits_outcome
          end
        end # Crown servant
        context "answer cross border worker" do
          should "state tax credits eligibility with exceptions" do
            add_response 'cross_border_worker'
            assert_current_node :tax_credits_exceptions
          end
        end # Cross border worker
        context "answer none of the above" do
          setup do
            add_response 'none_of_the_above'
          end
          should "ask how long you are abroad for" do
            assert_current_node :how_long_are_you_abroad_for?
          end
          context "answer less than a year" do
            setup do
              add_response 'up_to_a_year'
            end
            should "ask why you are going abroad" do
              assert_current_node :why_are_you_going_abroad?
            end
            context "answer holiday or business" do
              should "state tax credits can continue for 8 weeks" do
                add_response 'holiday_or_business_trip'
                assert_current_node :tax_credits_continue_8_weeks
              end
            end # going for holiday or business
            context "answer for medical treatment" do
              should "state that tax credits can continue for 12 weeks" do
                add_response 'medical_treatment'
                assert_current_node :tax_credits_continue_12_weeks
              end
            end # going for medical treatment
            context "answer death" do
              should "state that tax credits can continue for 12 weeks" do
                add_response 'death'
                assert_current_node :tax_credits_continue_12_weeks
              end
            end
          end # going abroad for less than a year
          context "answer more than a year" do
            setup do
              add_response 'more_than_a_year'
            end
            should "ask if you have children" do
              assert_current_node :do_you_have_children?
            end
            context "answer yes" do
              setup do
                add_response 'yes'
              end
              should "ask where you are moving to" do
                assert_current_node :where_are_you_moving_to_tax_credits?
              end
              context "answer Austria (EEA country)" do
                setup do
                  add_response 'austria'
                end
                should "ask whether you are currently claiming any of the following" do
                  assert_current_node :currently_claiming?
                end
                context "answer yes" do
                  should "state tax credit eligibility is possible" do
                    add_response 'yes'
                    assert_current_node :tax_credits_possible
                  end
                end
                context "answer no" do
                  should "state tax credits eligibility is unlikely" do
                    add_response 'no'
                    assert_current_node :tax_credits_unlikely
                  end
                end
              end # EEA country
              context "answer Australia" do
                should "state that tax credit eligibility is unlikely" do
                  add_response 'australia'
                  assert_current_node :tax_credits_unlikely
                end
              end # 'Other' country
            end # Yes have children
            context "answer no" do
              should "state tax credit eligibility" do
                add_response 'no'
                assert_current_node :tax_credits_outcome
              end
            end # No children
          end # going for more than a year
        end # None of the above
      end # Currently eligible for tax credits in the UK.
      context "answer no" do
        should "state that tax credit eligibility is unlikely" do
          add_response 'no'
          assert_current_node :tax_credits_unlikely
        end
      end # Not currently eligible for tax credits in UK.
    end # Tax credits
    context "answer ESA" do
      setup do
        add_response 'esa'
      end
      should "ask how long you are going abroad for" do
        assert_current_node :how_long_are_you_abroad_for_esa?
      end
      context "answer less than a year for medical care" do
        should "state 26 week eligibility" do
          add_response 'less_than_a_year_medical'
          assert_current_node :esa_eligible_26_weeks
        end
      end
      context "answer less than a year" do
        should "state 4 week eligibility" do
          add_response 'less_than_a_year'
          assert_current_node :esa_eligible_4_weeks
        end
      end
      context "answer more than a year" do
        setup do
          add_response 'more_than_a_year'
        end
        should "ask which country you are going to" do
          assert_current_node :which_country_are_you_moving_to_esa?
        end
        context "answer Austria" do
          should "state ESA eligibility is possible" do
            add_response 'austria'
            assert_current_node :esa_eligible_possible
          end
        end # EEA Country
        context "answer Australia" do
          should "state that you are not entitled to ESA" do
            add_response 'australia'
            assert_current_node :esa_not_entitled
          end
        end # 'Other' country
      end # going abroad for more than a year
    end # ESA
  end
end
