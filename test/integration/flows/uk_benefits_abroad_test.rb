# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'

class UKBenefitsAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    setup_for_testing_flow 'uk-benefits-abroad'
    worldwide_api_has_locations %w(albania austria canada jamaica kosovo)
  end

# Q1
  should "ask if you are going abroad or are already abroad" do
    assert_current_node :going_or_already_abroad?
  end

# Going abroad
  context "when going abroad" do
    setup do
      add_response "going_abroad"
    end
    
    should "ask which benefit you're interested in" do
      assert_current_node :which_benefit?
    end
    # answer JSA
    context "answer JSA" do
      setup do
        add_response 'jsa'
      end
      should "ask how long you're going abroad for" do
        assert_current_node :jsa_how_long_abroad?
      end

      context "answer less than a year for medical treatment" do
        setup do
          add_response 'less_than_a_year_medical'
        end
        should "take you to the 'less than a year for medical reasons' outcome" do
          assert_current_node :jsa_less_than_a_year_medical_outcome
        end
      end
      context "answer less than a year for other reasons" do
        setup do
          add_response 'less_than_a_year_other'
        end
        should "take you to the 'less than a year other' outcome" do
          assert_current_node :jsa_less_than_a_year_other_outcome
        end
      end
      context "answers more than a year" do
        setup do
          add_response 'more_than_a_year'
        end
        should "ask you the channel islands question" do
          assert_phrase_list :channel_islands_question_titles, [:ci_going_abroad_question_title]
          assert_current_node :channel_islands?
        end

        context "answer Guernsey or Jersey" do
          setup do
            add_response 'guernsey_jersey'
          end
          should "take you to JSA SS outcome" do
            assert_phrase_list :channel_islands_question_titles, [:ci_going_abroad_question_title]
            assert_phrase_list :channel_islands_prefix, [:ci_going_abroad_prefix]
            assert_current_node :jsa_social_security_going_abroad_outcome
          end
        end
        context "answer abroad" do
          setup do
            add_response "abroad"
          end
          should "take you to which country JSA question" do
            assert_current_node :which_country_jsa?
          end

          context "answer EEA country" do
            setup do
              add_response 'austria'
            end
            should "go to the JSA EEA outcome" do
              assert_current_node :jsa_eea_going_abroad_outcome
            end
          end
          context "answer SS country" do
            setup do
              add_response 'kosovo'
            end
            should "go to the JSA SS outcome" do
              assert_current_node :jsa_social_security_going_abroad_outcome
            end
          end
          context "answer 'other' country" do
            setup do
              add_response 'albania'
            end
            should "take you to JSA not entitled outcome" do
              assert_current_node :jsa_not_entitled_outcome
            end
          end
        end
      end
    end

    # answer State Pension
    context "answer State Pension" do
      setup do
        add_response 'pension'
      end
      should "take you to the pension going abroad outcome" do
        assert_current_node :pension_going_abroad_outcome
      end
    end

    # answer Winter Fuel Payment
    context "answer WFP" do
      setup do
        add_response 'winter_fuel_payment'
      end
      should "ask you which country you are moving to" do
        assert_current_node :which_country_wfp?
      end
      context "answer EEA country" do
        setup do
          add_response 'austria'
        end
        should "take you to eligible outcome" do
          assert_current_node :wfp_eea_eligible_outcome
        end
      end
      context "answer other country" do
        setup do
          add_response 'albania'
        end
        should "take you to not eligible outcome" do
          assert_current_node :wfp_not_eligible_outcome
        end
      end
    end

    # answer maternity benefits
    context "answer maternity benefits" do
      setup do
        add_response 'maternity_benefits'
      end
      should "ask you the Channel islands question" do
        assert_phrase_list :channel_islands_question_titles, [:ci_going_abroad_question_title]
        assert_current_node :channel_islands?
      end

      context "answer Guernsey or Jersey" do
        setup do
          add_response 'guernsey_jersey'
        end
        should "ask you if your employer pays NI contributions" do
          assert_current_node :employer_paying_ni?
        end

        context "answer yes" do
          setup do
            add_response 'yes'
          end
          should "ask are you eligible for SMP" do
            assert_current_node :eligible_for_smp?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "take you to SS eligible outcome" do
              assert_phrase_list :channel_islands_question_titles, [:ci_going_abroad_question_title]
              assert_phrase_list :channel_islands_prefix, [:ci_going_abroad_prefix]
              assert_current_node :maternity_benefits_eea_entitled_outcome
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to can't get SMP but may get MA outcome" do
              assert_current_node :maternity_benefits_maternity_allowance_outcome
            end
          end
        end
        context "answer no" do
          setup do
            add_response 'no'
          end
          should "take you to can't get SMP but may get MA outcome" do
            assert_current_node :maternity_benefits_social_security_going_abroad_outcome
          end
        end
      end

      context "answer abroad" do
        setup do
          add_response 'abroad'
        end
        should "take you to country select question" do
          assert_phrase_list :question_titles, [:going_abroad_country_question_title]
          assert_current_node :which_country_maternity_benefits?
        end

        context "answer EEA country" do
          setup do
            add_response 'austria'
          end
          should "ask are you working for a UK employer" do
            assert_current_node :working_for_a_uk_employer?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "ask if you're eligible for SMP" do
              assert_current_node :eligible_for_smp?
            end
            context "answer yes" do
              setup do
                add_response 'yes'
              end
              should "take you to EEA eligible outcome" do
                assert_current_node :maternity_benefits_eea_entitled_outcome
              end
            end
            context "answer no" do
              setup do
                add_response 'no'
              end
              should "take you to can't get SMP but may get MA outcome" do
                assert_current_node :maternity_benefits_maternity_allowance_outcome
              end
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to the can't get SMP but may get MA outcome" do
              assert_current_node :maternity_benefits_maternity_allowance_outcome
            end
          end
        end

        context "answer SS country" do
          setup do
            add_response 'kosovo'
          end
          should "ask if your empoyer is paying NI contributions" do
            assert_current_node :employer_paying_ni?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "take you to SMP question" do
              assert_current_node :eligible_for_smp?
            end
            context "answer yes" do
              setup do
                add_response 'yes'
              end
              should "take you to EEA entitled outcome" do
                assert_current_node :maternity_benefits_eea_entitled_outcome
              end
            end
            context "answer no" do
              setup do
                add_response 'no'
              end
              should "take you to can't get SMP but may get MA outcome" do
                assert_current_node :maternity_benefits_maternity_allowance_outcome
              end
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to SS going abroad outcome" do
              assert_current_node :maternity_benefits_social_security_going_abroad_outcome
            end
          end
        end

        context "answer 'other' country" do
          setup do
            add_response 'albania'
          end
          should "ask if your empoyer is paying NI contributions" do
            assert_current_node :employer_paying_ni?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "take you to SMP question" do
              assert_current_node :eligible_for_smp?
            end
            context "answer yes" do
              setup do
                add_response 'yes'
              end
              should "take you to SS entitled outcome" do
                assert_current_node :maternity_benefits_eea_entitled_outcome
              end
            end
            context "answer no" do
              setup do
                add_response 'no'
              end
              should "take you to not entitled outcome" do
                assert_current_node :maternity_benefits_maternity_allowance_outcome
              end
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to not entitled outcome" do
              assert_current_node :maternity_benefits_not_entitled_outcome
            end
          end
        end
      end
    end

    # answer Child benefits
    context "answer child benefits" do
      setup do
        add_response 'child_benefits'
      end
      should "ask you the Channel islands question" do
        assert_phrase_list :channel_islands_question_titles, [:ci_going_abroad_question_title]
        assert_current_node :channel_islands?
      end

      context "answer Guernsey or Jersey" do
        setup do
          add_response 'guernsey_jersey'
        end
        should "take you to SS outcome" do
          assert_current_node :child_benefits_ss_outcome
        end
      end
      context "answer abroad" do
        setup do
          add_response 'abroad'
        end
        should "take you to which country question" do
          assert_current_node :which_country_child_benefits?
        end

        context "answer EEA country" do
          setup do
            add_response 'austria'
          end
          should "ask you do any of the following apply" do
            assert_current_node :do_either_of_the_following_apply?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "take you to the entitled outcome" do
              assert_current_node :child_benefits_entitled_outcome
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to not entitled outcome" do
              assert_current_node :child_benefits_not_entitled_outcome
            end
          end
        end
        context "answer FY country" do
          setup do
            add_response 'kosovo'
          end
          should "take you to FY going abroad outcome" do
            assert_current_node :child_benefits_fy_going_abroad_outcome
          end
        end
        context "answer SS country" do
          setup do
            add_response 'canada'
          end
          should "take you to SS outcome" do
            assert_current_node :child_benefits_ss_outcome
          end
        end
        context "answer JTU country" do
          setup do
            add_response 'jamaica'
          end
          should "take you to JTU outcome" do
            assert_current_node :child_benefits_jtu_outcome
          end
        end
        context "answer other country" do
          setup do
            add_response 'albania'
          end
          should "take you to not entitled outcome" do
            assert_current_node :child_benefits_not_entitled_outcome
          end
        end
      end
    end

    # answer SSP
    context "answer statutory sick pay (SSP)" do
      setup do
        add_response 'ssp'
      end
      should "ask which country are you moving to" do
        assert_current_node :which_country_ssp?
      end

      context "answer EEA country" do
        setup do
          add_response 'austria'
        end
        should "ask you are you working for a UK employer" do
          assert_current_node :working_for_uk_employer_ssp?
        end
        context "answer yes" do
          setup do
            add_response 'yes'
          end
          should "take you to the entitled outcome" do
            assert_current_node :ssp_going_abroad_entitled_outcome
          end
        end
        context "answer no" do
          setup do
            add_response 'no'
          end
          should "take you to not entitled outcome" do
            assert_current_node :ssp_going_abroad_not_entitled_outcome
          end
        end
      end

      context "answer other country" do
        setup do
          add_response 'albania'
        end
        should "ask is your employer paying NI contributions for you" do
          assert_current_node :employer_paying_ni_ssp?
        end
        context "answer yes" do
          setup do
            add_response 'yes'
          end
          should "take you to the entitled outcome" do
            assert_current_node :ssp_going_abroad_entitled_outcome
          end
        end
        context "answer no" do
          setup do
            add_response 'no'
          end
          should "take you to not entitled outcome" do
            assert_current_node :ssp_going_abroad_not_entitled_outcome
          end
        end
      end
    end

    # answer Tax Credis
    context "answer tax credits" do
      setup do
        add_response 'tax_credits'
      end
      should "ask if you or partner is a crown servant or cross-border worker" do
        assert_current_node :eligible_for_tax_credits?
      end
      context "answer crown servant" do
        setup do
          add_response 'crown_servant'
        end
        should "take you to crown servant outcome" do
          assert_current_node :tax_credits_crown_servant_outcome
          assert_phrase_list :tax_credits_crown_servant, [:tax_credits_going_abroad_helpline]
        end
      end
      context "answer cross-border worker" do
        setup do
          add_response 'cross_border_worker'
        end
        should "take you to cross-border worker outcome" do
          assert_current_node :tax_credits_cross_border_worker_outcome
          assert_phrase_list :tax_credits_cross_border_worker, [:tax_credits_cross_border_going_abroad, :tax_credits_cross_border, :tax_credits_going_abroad_helpline]
        end
      end
      context "answer none of the above" do
        setup do
          add_response 'none_of_the_above'
        end
        should "ask how long you're going abroad for" do
          assert_current_node :tax_credits_how_long_abroad?
        end

        context "answer less than a year" do
          setup do
            add_response :tax_credits_up_to_a_year
          end
          should "ask why are you going abroad" do
            assert_current_node :tax_credits_why_going_abroad?
          end
          context "answer holiday" do
            setup do
              add_response 'tax_credits_holiday'
            end
            should "take you to the holiday outcome" do
              assert_current_node :tax_credits_holiday_outcome
              assert_phrase_list :tax_credits_holiday, [:tax_credits_holiday_going_abroad, :tax_credits_holiday, :tax_credits_going_abroad_helpline]
            end
          end
          context "answer medical treatment" do
            setup do
              add_response 'tax_credits_medical_treatment'
            end
            should "take you to medical treatment outcome" do
              assert_current_node :tax_credits_medical_death_outcome
              assert_phrase_list :tax_credits_medical_death, [:tax_credits_medical_death_going_abroad, :tax_credits_medical_death, :tax_credits_going_abroad_helpline]
            end
          end
          context "answer family bereavement" do
            setup do
              add_response 'tax_credits_death'
            end
            should "take you to family bereavement outcome" do
              assert_current_node :tax_credits_medical_death_outcome
              assert_phrase_list :tax_credits_medical_death, [:tax_credits_medical_death_going_abroad, :tax_credits_medical_death, :tax_credits_going_abroad_helpline]
            end
          end
        end
        context "answer more than a year" do
          setup do
            add_response 'tax_credits_more_than_a_year'
          end
          should "ask if you have children" do
            assert_current_node :tax_credits_children?
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "take you to unlikely outcome" do
              assert_current_node :tax_credits_unlikely_outcome
            end
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "ask you what country you're moving to" do
              assert_current_node :which_country_tax_credits?
            end
            context "answer EEA country" do
              setup do
                add_response 'austria'
              end
              should "ask are you claiming any of these benefits" do
                assert_current_node :tax_credits_currently_claiming?
              end
              context "answer yes" do
                setup do
                  add_response 'yes'
                end
                should "take you to EEA may qualify outcome" do
                  assert_current_node :tax_credits_eea_entitled_outcome
                end
              end
              context "answer no" do
                setup do
                  add_response 'no'
                end
                should "take you to not entitled outcome" do
                  assert_current_node :tax_credits_unlikely_outcome
                end
              end
            end
            context "answer other country" do
              setup do
                add_response 'albania'
              end
              should "take you to not entitled outcome" do
                assert_current_node :tax_credits_unlikely_outcome
              end
            end
          end
        end

      end
    end

  end
# end Going Abroad

# Already abroad
  context "already abroad" do
    setup do
      add_response "already_abroad"
    end
    
    should "ask which benefit you're interested in" do
      assert_current_node :which_benefit?
    end
    # answer JSA
    context "answer JSA, Guernsey (SS)" do
      setup do
        add_response 'jsa'
        add_response 'guernsey_jersey'
      end
      should "take you to JSA SS outcome" do
        assert_phrase_list :channel_islands_question_titles, [:ci_already_abroad_question_title]
        assert_phrase_list :channel_islands_prefix, [:ci_already_abroad_prefix]
        assert_current_node :jsa_social_security_already_abroad_outcome
      end
    end
    context "answer JSA EEA country" do
      setup do
        add_response 'jsa'
        add_response "abroad"
        add_response 'austria'
      end
      should "take you to JSA EEA outcome" do
        assert_current_node :jsa_eea_already_abroad_outcome
      end
    end
    context "answer JSA SS country" do
      setup do
        add_response 'jsa'
        add_response 'abroad'
        add_response 'kosovo'
      end
      should "take you to JSA SS outcome" do
        assert_current_node :jsa_social_security_already_abroad_outcome
      end
    end
    context "answer JSA other country" do
      setup do
        add_response 'jsa'
        add_response 'abroad'
        add_response 'albania'
      end
      should "take you to JSA other country outcome" do
        assert_current_node :jsa_not_entitled_outcome
      end
    end

    # answer State Pension
    context "answer State Pension" do
      setup do
        add_response 'pension'
      end
      should "take you to the pension already abroad outcome" do
        assert_current_node :pension_already_abroad_outcome
      end
    end

    # answer Winter Fuel Payment
    context "answer WFP EEA country" do
      setup do
        add_response 'winter_fuel_payment'
        add_response 'austria'
      end
      should "take you to eligible outcome" do
        assert_current_node :wfp_eea_eligible_outcome
      end
    end
    context "answer WFP other country" do
      setup do
        add_response 'winter_fuel_payment'
        add_response 'albania'
      end
      should "take you to not eligible outcome" do
        assert_current_node :wfp_not_eligible_outcome
      end
    end

    # answer Maternity benefits
    context "answer Guernsey/Jersey, employer paying NI, eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'guernsey_jersey'
        add_response 'yes'
        add_response 'yes'
      end
      should "take you to SMP entitled outcome" do
        assert_current_node :maternity_benefits_eea_entitled_outcome
      end
    end
    context "answer Guernsey/Jersey, employer paying NI, not eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'guernsey_jersey'
        add_response 'yes'
        add_response 'no'
      end
      should "take you to SS can't get SMP but may get MA outcome" do
        assert_phrase_list :channel_islands_prefix, [:ci_already_abroad_prefix]
        assert_current_node :maternity_benefits_maternity_allowance_outcome
      end
    end
    context "answer Guernsey/Jersey, employer paying NI" do
      setup do
        add_response 'maternity_benefits'
        add_response 'guernsey_jersey'
        add_response 'no'
      end
      should "take you to SS can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_social_security_already_abroad_outcome
      end
    end
    context "answer EEA country, working for UK employer, eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'austria'
        add_response 'yes'
        add_response 'yes'
      end
      should "take you to SMP entitled outcome" do
        assert_current_node :maternity_benefits_eea_entitled_outcome
      end
    end
    context "answer EEA country, working for UK employer, not eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'austria'
        add_response 'yes'
        add_response 'no'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_maternity_allowance_outcome
      end
    end
    context "answer EEA country, not working for UK employer" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'austria'
        add_response 'no'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_maternity_allowance_outcome
      end
    end
    context "answer SS country, employer paying NI, eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'kosovo'
        add_response 'yes'
        add_response 'yes'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_eea_entitled_outcome
      end
    end
    context "answer SS country, employer paying NI, not eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'kosovo'
        add_response 'yes'
        add_response 'no'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_maternity_allowance_outcome
      end
    end
    context "answer SS country, employer not paying NI" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'kosovo'
        add_response 'no'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_social_security_already_abroad_outcome
      end
    end
    context "answer other country, employer paying NI, eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'albania'
        add_response 'yes'
        add_response 'yes'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_eea_entitled_outcome
      end
    end
    context "answer other country, employer paying NI, not eligible for SMP" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'albania'
        add_response 'yes'
        add_response 'no'
      end
      should "take you to can't get SMP but may get MA outcome" do
        assert_current_node :maternity_benefits_maternity_allowance_outcome
      end
    end
    context "answer other country, employer not paying NI" do
      setup do
        add_response 'maternity_benefits'
        add_response 'abroad'
        add_response 'albania'
        add_response 'no'
      end
      should "take you to not entitled outcome" do
        assert_current_node :maternity_benefits_not_entitled_outcome
      end
    end

    # answer Child benefits
    context "answer Guernsey/Jersey" do
      setup do
        add_response 'child_benefits'
        add_response 'guernsey_jersey'
      end
      should "take you to SS outcome" do
        assert_current_node :child_benefits_ss_outcome
      end
    end
    context "answer EEA country, paying NI in the UK" do
      setup do
        add_response 'child_benefits'
        add_response 'abroad'
        add_response 'austria'
        add_response 'yes'
      end
      should "take you to entitled outcome" do
        assert_current_node :child_benefits_entitled_outcome
      end
    end
    context "answer EEA country, not paying NI in the UK, not receiving benefits" do
      setup do
        add_response 'child_benefits'
        add_response 'abroad'
        add_response 'austria'
        add_response 'no'
      end
      should "take you to not entitled outcome" do
        assert_current_node :child_benefits_not_entitled_outcome
      end
    end
    context "answer FY country" do
      setup do
        add_response 'child_benefits'
        add_response 'abroad'
        add_response 'kosovo'
      end
      should "take you to FY already abroad outcome" do
        assert_current_node :child_benefits_fy_already_abroad_outcome
      end
    end
    context "answer SS country" do
      setup do
        add_response 'child_benefits'
        add_response 'abroad'
        add_response 'canada'
      end
      should "take you to SS outcome" do
        assert_current_node :child_benefits_ss_outcome
      end
    end
    context "answer JTU country" do
      setup do
        add_response 'child_benefits'
        add_response 'abroad'
        add_response 'jamaica'
      end
      should "take you to JTU outcome" do
        assert_current_node :child_benefits_jtu_outcome
      end
    end

    # answer Statutory Sick Pay (SSP)
    context "answer EEA country, working for a UK employer" do
      setup do
        add_response 'ssp'
        add_response 'austria'
        add_response 'yes'
      end
      should "take you to entitled outcome" do
        assert_current_node :ssp_already_abroad_entitled_outcome
      end
    end
    context "answer EEA country, not working for a UK employer" do
      setup do
        add_response 'ssp'
        add_response 'austria'
        add_response 'no'
      end
      should "take you to entitled outcome" do
        assert_current_node :ssp_already_abroad_not_entitled_outcome
      end
    end
    context "answer other country, employer paying NI" do
      setup do
        add_response 'ssp'
        add_response 'albania'
        add_response 'yes'
      end
      should "take you to entitled outcome" do
        assert_current_node :ssp_already_abroad_entitled_outcome
      end
    end
    context "answer other country, employer not paying NI" do
      setup do
        add_response 'ssp'
        add_response 'albania'
        add_response 'no'
      end
      should "take you to entitled outcome" do
        assert_current_node :ssp_already_abroad_not_entitled_outcome
      end
    end

    # answer Tax Credits
    context "answer crown servant" do
      setup do
        add_response 'tax_credits'
        add_response 'crown_servant'
      end
      should "take you to crown servant outcome" do
        assert_current_node :tax_credits_crown_servant_outcome
        assert_phrase_list :tax_credits_crown_servant, [:tax_credits_already_abroad_helpline]
      end
    end
    context "answer cross-border worker" do
      setup do
        add_response 'tax_credits'
        add_response 'cross_border_worker'
      end
      should "take you to cross-border worker outcome" do
        assert_current_node :tax_credits_cross_border_worker_outcome
        assert_phrase_list :tax_credits_cross_border_worker, [:tax_credits_cross_border_already_abroad, :tax_credits_cross_border, :tax_credits_already_abroad_helpline]
      end
    end
    context "not crown or cross, abroad less than a year, holiday" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_up_to_a_year'
        add_response 'tax_credits_holiday'
      end
      should "take you to the holiday outcome" do
        assert_current_node :tax_credits_holiday_outcome
        assert_phrase_list :tax_credits_holiday, [:tax_credits_holiday_already_abroad, :tax_credits_holiday, :tax_credits_already_abroad_helpline]
      end
    end
    context "not crown or cross, abroad less than a year, medical treatment" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_up_to_a_year'
        add_response 'tax_credits_medical_treatment'
      end
      should "take you to the medical treatment outcome" do
        assert_current_node :tax_credits_medical_death_outcome
        assert_phrase_list :tax_credits_medical_death, [:tax_credits_medical_death_already_abroad, :tax_credits_medical_death, :tax_credits_already_abroad_helpline]
      end
    end
    context "not crown or cross, abroad less than a year, family bereavement" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_up_to_a_year'
        add_response 'tax_credits_death'
      end
      should "take you to the family bereavment outcome" do
        assert_current_node :tax_credits_medical_death_outcome
        assert_phrase_list :tax_credits_medical_death, [:tax_credits_medical_death_already_abroad, :tax_credits_medical_death, :tax_credits_already_abroad_helpline]
      end
    end
    context "not crown or cross, abroad more than a year, no children" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_more_than_a_year'
        add_response 'no'
      end
      should "take you to unlikely outcome" do
        assert_current_node :tax_credits_unlikely_outcome
      end
    end
    context "not crown or cross, abroad more than a year, children, EEA country, benefits" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_more_than_a_year'
        add_response 'yes'
        add_response 'austria'
        add_response 'yes'
      end
      should "take you to entitled outcome" do
        assert_current_node :tax_credits_eea_entitled_outcome
      end
    end
    context "not crown or cross, abroad more than a year, children, EEA country, no benefits" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_more_than_a_year'
        add_response 'yes'
        add_response 'austria'
        add_response 'no'
      end
      should "take you to unlikely outcome" do
        assert_current_node :tax_credits_unlikely_outcome
      end
    end
    context "not crown or cross, abroad more than a year, children, other country" do
      setup do
        add_response 'tax_credits'
        add_response 'none_of_the_above'
        add_response 'tax_credits_more_than_a_year'
        add_response 'yes'
        add_response 'albania'
      end
      should "take you to unlikely outcome" do
        assert_current_node :tax_credits_unlikely_outcome
      end
    end

  end # end Already Abroad
end