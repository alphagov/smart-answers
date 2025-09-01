require "test_helper"
require "support/flow_test_helper"

# noinspection RubyResolve
class UkBenefitsAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow UkBenefitsAbroadFlow
    stub_worldwide_api_has_locations(
      %w[
        australia
        barbados
        bermuda
        canada
        gibraltar
        guernsey
        ireland
        israel
        jamaica
        jersey
        liechtenstein
        mauritius
        new-zealand
        north-macedonia
        turkey
        usa
      ],
    )
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: going_or_already_abroad?" do
    setup { testing_node :going_or_already_abroad? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[going_abroad already_abroad].each do |response|
        should "have a next node of which_benefit? for a '#{response}' response" do
          assert_next_node :which_benefit?, for_response: response
        end
      end
    end
  end

  context "question: which_benefit?" do
    setup do
      testing_node :which_benefit?
      add_responses going_or_already_abroad?: "going_abroad"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      %w[maternity_benefits child_benefit ssp bereavement_benefits jsa].each do |benefit|
        should "have a next node of which_country? for a '#{benefit}' response if going_abroad" do
          assert_next_node :which_country?, for_response: benefit
        end
      end

      should "have a next node of wfp_not_eligible_outcome for an 'winter_fuel_payment' response" do
        assert_next_node :wfp_not_eligible_outcome, for_response: "winter_fuel_payment"
      end

      should "have a next node of iidb_already_claiming? for an 'iidb' response" do
        assert_next_node :iidb_already_claiming?, for_response: "iidb"
      end

      should "have a next node of esa_how_long_abroad? for an 'esa' response" do
        assert_next_node :esa_how_long_abroad?, for_response: "esa"
      end

      should "have a next node of db_how_long_abroad? for a 'disability_benefits' response" do
        assert_next_node :db_how_long_abroad?, for_response: "disability_benefits"
      end

      should "have a next node of eligible_for_tax_credits? for a 'tax_credits' response" do
        assert_next_node :eligible_for_tax_credits?, for_response: "tax_credits"
      end

      should "have a next node of pension_going_abroad_outcome for a 'pension' response if going_abroad" do
        assert_next_node :pension_going_abroad_outcome, for_response: "pension"
      end

      should "have a next node of is_how_long_abroad? for an 'income_support' response if going_abroad" do
        assert_next_node :is_how_long_abroad?, for_response: "income_support"
      end

      should "have a next node of pension_already_abroad_outcome for a 'pension' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :pension_already_abroad_outcome, for_response: "pension"
      end

      should "have a next node of is_already_abroad_outcome for an 'income_support' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :is_already_abroad_outcome, for_response: "income_support"
      end
    end
  end

  context "question: which_country?" do
    setup do
      testing_node :which_country?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "jsa"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      context "jsa" do
        should "have a next node of jsa_eea_already_abroad_outcome for any EEA country response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :jsa_eea_already_abroad_outcome, for_response: "liechtenstein"
        end

        should "have a next node of jsa_social_security_already_abroad_outcome for any social security country without JSA response and if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :jsa_social_security_already_abroad_outcome, for_response: "north-macedonia"
        end

        should "have a next node of is_british_or_irish? for an 'ireland' response if going_abroad" do
          assert_next_node :is_british_or_irish?, for_response: "ireland"
        end

        should "have a next node of jsa_eea_going_abroad_maybe_outcome for a 'gibraltar' response if going_abroad" do
          assert_next_node :jsa_eea_going_abroad_maybe_outcome, for_response: "gibraltar"
        end

        should "have a next node of worked_in_eea_or_switzerland? for any EEA country response if going_abroad" do
          assert_next_node :worked_in_eea_or_switzerland?, for_response: "liechtenstein"
        end

        should "have a next node of jsa_social_security_going_abroad_outcome for any social security country without JSA response and if going_abroad" do
          assert_next_node :jsa_social_security_going_abroad_outcome, for_response: "north-macedonia"
        end

        should "have a next node of jsa_not_entitled_outcome for any non-jsa or non-EEA country response" do
          assert_next_node :jsa_not_entitled_outcome, for_response: "australia"
        end
      end

      context "maternity_benefits" do
        setup do
          add_responses which_benefit?: "maternity_benefits"
        end

        should "have a next node of working_for_a_uk_employer? for any EEA country response" do
          assert_next_node :working_for_a_uk_employer?, for_response: "liechtenstein"
        end

        should "have a next node of employer_paying_ni? for any non-EEA country response" do
          assert_next_node :employer_paying_ni?, for_response: "australia"
        end
      end

      context "child_benefit" do
        setup do
          add_responses which_benefit?: "child_benefit"
        end

        should "have a next node of do_either_of_the_following_apply? for any EEA country response" do
          assert_next_node :do_either_of_the_following_apply?, for_response: "liechtenstein"
        end

        should "have a next node of child_benefit_fy_going_abroad_outcome for any social security country with child benefit response and if going_abroad" do
          assert_next_node :child_benefit_fy_going_abroad_outcome, for_response: "north-macedonia"
        end

        should "have a next node of child_benefit_fy_already_abroad_outcome for any social security country with child benefit response and if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :child_benefit_fy_already_abroad_outcome, for_response: "north-macedonia"
        end

        %w[barbados canada guernsey israel jersey mauritius new-zealand].each do |country|
          should "have a next node of child_benefit_ss_outcome for a '#{country}' response" do
            assert_next_node :child_benefit_ss_outcome, for_response: country
          end
        end

        %w[jamaica turkey usa].each do |country|
          should "have a next node of child_benefit_jtu_outcome for a '#{country}' response" do
            assert_next_node :child_benefit_jtu_outcome, for_response: country
          end
        end

        should "have a next node of child_benefit_not_entitled_outcome for any other country response" do
          assert_next_node :child_benefit_not_entitled_outcome, for_response: "australia"
        end
      end

      context "iidb" do
        setup do
          add_responses which_benefit?: "iidb",
                        iidb_already_claiming?: "yes"
        end

        should "have next node of iidb_going_abroad_eea_outcome for any response in and EEA country if going_abroad" do
          assert_next_node :iidb_going_abroad_eea_outcome, for_response: "liechtenstein"
        end

        should "have next node of iidb_going_abroad_ss_outcome for any response not in EEA but in social security country with iidb if going_abroad" do
          assert_next_node :iidb_going_abroad_ss_outcome, for_response: "north-macedonia"
        end

        should "have next node of iidb_going_abroad_eea_outcome for any response not in EEA and not in social security country with iidb if going_abroad" do
          assert_next_node :iidb_going_abroad_eea_outcome, for_response: "australia"
        end

        should "have next node of iidb_already_abroad_eea_outcome for any response in an EEA country if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :iidb_already_abroad_eea_outcome, for_response: "liechtenstein"
        end

        should "have next node of iidb_already_abroad_ss_outcome for any response not in EEA but in social security country with iidb if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :iidb_already_abroad_ss_outcome, for_response: "north-macedonia"
        end

        should "have next node of iidb_already_abroad_eea_outcome for any response not in EEA and not in social security country with iidb if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :iidb_already_abroad_eea_outcome, for_response: "australia"
        end
      end

      context "disability_benefits" do
        setup do
          add_responses which_benefit?: "disability_benefits",
                        db_how_long_abroad?: "permanent"
        end

        should "have a next node of worked_in_eea_or_switzerland? for any EEA country" do
          assert_next_node :worked_in_eea_or_switzerland?, for_response: "liechtenstein"
        end

        should "have a next node of db_going_abroad_other_outcome for any response not in EEA country if going_abroad" do
          assert_next_node :db_going_abroad_other_outcome, for_response: "australia"
        end

        should "have a next node of db_already_abroad_other_outcome for any response not in EEA country if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :db_already_abroad_other_outcome, for_response: "australia"
        end
      end

      context "ssp" do
        setup do
          add_responses which_benefit?: "ssp"
        end

        should "have a next node of working_for_uk_employer_ssp? for any response in EEA country" do
          assert_next_node :working_for_uk_employer_ssp?, for_response: "liechtenstein"
        end

        should "have a next node of employer_paying_ni? for any response not in EEA country" do
          assert_next_node :employer_paying_ni?, for_response: "australia"
        end
      end

      context "tax_credits" do
        setup do
          add_responses which_benefit?: "tax_credits",
                        eligible_for_tax_credits?: "none_of_the_above",
                        tax_credits_how_long_abroad?: "tax_credits_more_than_a_year",
                        tax_credits_children?: "yes"
        end

        should "have a next node of tax_credits_currently_claiming? for any response in EEA country" do
          assert_next_node :tax_credits_currently_claiming?, for_response: "liechtenstein"
        end

        should "have a next node of tax_credits_unlikely_outcome for any response not in EEA country" do
          assert_next_node :tax_credits_unlikely_outcome, for_response: "australia"
        end
      end

      context "esa" do
        setup do
          add_responses which_benefit?: "esa",
                        esa_how_long_abroad?: "esa_more_than_a_year"
        end

        should "have a next node of is_british_or_irish? for an 'ireland' response if going_abroad" do
          assert_next_node :is_british_or_irish?, for_response: "ireland"
        end

        should "have a next node of esa_going_abroad_eea_outcome for any former Yugoslavia response if going_abroad" do
          assert_next_node :esa_going_abroad_eea_outcome, for_response: "north-macedonia"
        end

        %w[barbados guernsey gibraltar israel jersey jamaica turkey usa].each do |country|
          should "have a next node of esa_going_abroad_eea_outcome for a '#{country}' response if going_abroad" do
            assert_next_node :esa_going_abroad_eea_outcome, for_response: country
          end
        end

        should "have a next node of worked_in_eea_or_switzerland? for any EEA country response if going_abroad" do
          assert_next_node :worked_in_eea_or_switzerland?, for_response: "liechtenstein"
        end

        should "have a next node of esa_going_abroad_other_outcome for any other country response if going_abroad" do
          assert_next_node :esa_going_abroad_other_outcome, for_response: "australia"
        end

        should "have a next node of is_british_or_irish? for an 'ireland' response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :is_british_or_irish?, for_response: "ireland"
        end

        should "have a next node of esa_already_abroad_eea_outcome for an 'gibraltar' response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :esa_already_abroad_eea_outcome, for_response: "gibraltar"
        end

        should "have a next node of esa_already_abroad_ss_outcome for any former Yugoslavia response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :esa_already_abroad_ss_outcome, for_response: "north-macedonia"
        end

        %w[barbados jersey guernsey jamaica turkey usa].each do |country|
          should "have a next node of esa_already_abroad_ss_outcome for a '#{country}' response if already_abroad" do
            add_responses going_or_already_abroad?: "already_abroad"
            assert_next_node :esa_already_abroad_ss_outcome, for_response: country
          end
        end

        should "have a next node of esa_already_abroad_other_outcome for any other country if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :esa_already_abroad_other_outcome, for_response: "australia"
        end
      end

      context "bereavement_benefits" do
        setup do
          add_responses which_benefit?: "bereavement_benefits"
        end

        should "have a next node of bb_going_abroad_eea_outcome for any response in EEA country if going_abroad" do
          assert_next_node :bb_going_abroad_eea_outcome, for_response: "liechtenstein"
        end

        should "have a next node of bb_going_abroad_ss_outcome for any response in social security country with bereavement benefits if going_abroad" do
          assert_next_node :bb_going_abroad_ss_outcome, for_response: "north-macedonia"
        end

        should "have a next node of bb_going_abroad_other_outcome for any other country if going_abroad" do
          assert_next_node :bb_going_abroad_other_outcome, for_response: "australia"
        end

        should "have a next node of bb_already_abroad_eea_outcome for any response in EEA country if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :bb_already_abroad_eea_outcome, for_response: "liechtenstein"
        end

        should "have a next node of bb_already_abroad_ss_outcome for any response in social security country with bereavement benefits if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :bb_already_abroad_ss_outcome, for_response: "north-macedonia"
        end

        should "have a next node of bb_already_abroad_other_outcome for any other country response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad"
          assert_next_node :bb_already_abroad_other_outcome, for_response: "australia"
        end
      end
    end
  end

  context "question: working_for_a_uk_employer?" do
    setup do
      testing_node :working_for_a_uk_employer?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "maternity_benefits",
                    which_country?: "liechtenstein"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of eligible_for_smp? for a 'yes' response" do
        assert_next_node :eligible_for_smp?, for_response: "yes"
      end

      should "have a next node of maternity_benefits_maternity_allowance_outcome for a 'no' response" do
        assert_next_node :maternity_benefits_maternity_allowance_outcome, for_response: "no"
      end
    end
  end

  context "question: eligible_for_smp?" do
    setup do
      testing_node :eligible_for_smp?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "maternity_benefits",
                    which_country?: "liechtenstein",
                    working_for_a_uk_employer?: "yes"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of maternity_benefits_eea_entitled_outcome for a 'yes' response" do
        assert_next_node :maternity_benefits_eea_entitled_outcome, for_response: "yes"
      end

      should "have a next node of maternity_benefits_maternity_allowance_outcome for a 'no' response" do
        assert_next_node :maternity_benefits_maternity_allowance_outcome, for_response: "no"
      end
    end
  end

  context "question: employer_paying_ni?" do
    setup do
      testing_node :employer_paying_ni?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "ssp",
                    which_country?: "australia"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of ssp_going_abroad_entitled_outcome for a 'yes' response if benefit is ssp and going_abroad" do
        assert_next_node :ssp_going_abroad_entitled_outcome, for_response: "yes"
      end

      should "have a next node of ssp_going_abroad_not_entitled_outcome for a 'no' response if benefit is ssp and going_abroad" do
        assert_next_node :ssp_going_abroad_not_entitled_outcome, for_response: "no"
      end

      should "have a next node of ssp_already_abroad_entitled_outcome for a 'yes' response if benefit is ssp and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :ssp_already_abroad_entitled_outcome, for_response: "yes"
      end

      should "have a next node of ssp_already_abroad_not_entitled_outcome for a 'no' response if benefit is ssp and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :ssp_already_abroad_not_entitled_outcome, for_response: "no"
      end

      should "have a next node of eligible_for_smp? for a 'yes' response if benefit is not ssp" do
        add_responses which_benefit?: "maternity_benefits"
        assert_next_node :eligible_for_smp?, for_response: "yes"
      end

      should "have a next node of maternity_benefits_social_security_going_abroad_outcome for a 'no' response if benefit is not ssp, country has no ssp and going_abroad" do
        add_responses which_country?: "north-macedonia",
                      which_benefit?: "maternity_benefits"
        assert_next_node :maternity_benefits_social_security_going_abroad_outcome, for_response: "no"
      end

      should "have a next node of maternity_benefits_social_security_already_abroad_outcome for a 'no' response if benefit is not ssp, country has no ssp and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_country?: "north-macedonia",
                      which_benefit?: "maternity_benefits"
        assert_next_node :maternity_benefits_social_security_already_abroad_outcome, for_response: "no"
      end

      should "have a next node of maternity_benefits_not_entitled_outcome for a 'no' response if benefit is not ssp and country has ssp" do
        add_responses which_country?: "australia",
                      which_benefit?: "maternity_benefits"
        assert_next_node :maternity_benefits_not_entitled_outcome, for_response: "no"
      end
    end
  end

  context "question: do_either_of_the_following_apply?" do
    setup do
      testing_node :do_either_of_the_following_apply?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "child_benefit",
                    which_country?: "liechtenstein"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of child_benefit_entitled_outcome for any response" do
        assert_next_node :child_benefit_entitled_outcome, for_response: "bereavement_benefits"
      end

      should "have a next node of child_benefit_not_entitled_outcome for an empty response" do
        assert_next_node :child_benefit_not_entitled_outcome, for_response: ""
      end
    end
  end

  context "question: working_for_uk_employer_ssp?" do
    setup do
      testing_node :working_for_uk_employer_ssp?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "ssp",
                    which_country?: "liechtenstein"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of ssp_going_abroad_entitled_outcome for a 'yes' response if going_abroad" do
        assert_next_node :ssp_going_abroad_entitled_outcome, for_response: "yes"
      end

      should "have a next node of ssp_going_abroad_not_entitled_outcome for a 'no' response if going_abroad" do
        assert_next_node :ssp_going_abroad_not_entitled_outcome, for_response: "no"
      end

      should "have a next node of ssp_already_abroad_entitled_outcome for a 'yes' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :ssp_already_abroad_entitled_outcome, for_response: "yes"
      end

      should "have a next node of ssp_already_abroad_not_entitled_outcome for a 'no' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :ssp_already_abroad_not_entitled_outcome, for_response: "no"
      end
    end
  end

  context "question: eligible_for_tax_credits?" do
    setup do
      testing_node :eligible_for_tax_credits?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of tax_credits_crown_servant_outcome for a 'crown_servant' response" do
        assert_next_node :tax_credits_crown_servant_outcome, for_response: "crown_servant"
      end

      should "have a next node of tax_credits_cross_border_worker_outcome for a 'cross_border_worker' response" do
        assert_next_node :tax_credits_cross_border_worker_outcome, for_response: "cross_border_worker"
      end

      should "have a next node of tax_credits_how_long_abroad? for a 'none_of_the_above' response" do
        assert_next_node :tax_credits_how_long_abroad?, for_response: "none_of_the_above"
      end
    end
  end

  context "question: tax_credits_children?" do
    setup do
      testing_node :tax_credits_children?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above",
                    tax_credits_how_long_abroad?: "tax_credits_more_than_a_year"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of which_country? for a 'yes' response" do
        assert_next_node :which_country?, for_response: "yes"
      end

      should "have a next node of tax_credits_unlikely_outcome for a 'no' response" do
        assert_next_node :tax_credits_unlikely_outcome, for_response: "no"
      end
    end
  end

  context "question: tax_credits_currently_claiming?" do
    setup do
      testing_node :tax_credits_currently_claiming?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above",
                    tax_credits_how_long_abroad?: "tax_credits_more_than_a_year",
                    tax_credits_children?: "yes",
                    which_country?: "liechtenstein"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of tax_credits_eea_entitled_outcome for any response" do
        assert_next_node :tax_credits_eea_entitled_outcome, for_response: "state_pension"
      end

      should "have a next node of tax_credits_unlikely_outcome for an empty response" do
        assert_next_node :tax_credits_unlikely_outcome, for_response: ""
      end
    end
  end

  context "question: tax_credits_why_going_abroad?" do
    setup do
      testing_node :tax_credits_why_going_abroad?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above",
                    tax_credits_how_long_abroad?: "tax_credits_up_to_a_year"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of tax_credits_holiday_outcome for a 'tax_credits_holiday' response" do
        assert_next_node :tax_credits_holiday_outcome, for_response: "tax_credits_holiday"
      end

      should "have a next node of tax_credits_medical_death_outcome for a 'tax_credits_medical_treatment' response" do
        assert_next_node :tax_credits_medical_death_outcome, for_response: "tax_credits_medical_treatment"
      end

      should "have a next node of tax_credits_medical_death_outcome for a 'tax_credits_death' response" do
        assert_next_node :tax_credits_medical_death_outcome, for_response: "tax_credits_death"
      end
    end
  end

  context "question: iidb_already_claiming?" do
    setup do
      testing_node :iidb_already_claiming?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "iidb"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of which_country? for a 'yes' response" do
        assert_next_node :which_country?, for_response: "yes"
      end

      should "have a next node of iidb_maybe_outcome for a 'no' response" do
        assert_next_node :iidb_maybe_outcome, for_response: "no"
      end
    end
  end

  context "question: is_claiming_benefits?" do
    setup do
      testing_node :is_claiming_benefits?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support",
                    db_how_long_abroad?: "permanent",
                    is_how_long_abroad?: "is_under_a_year_other"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_claiming_benefits_outcome for any response" do
        assert_next_node :is_claiming_benefits_outcome, for_response: "pension_premium"
      end

      should "have a next node of is_either_of_the_following? for an empty response" do
        assert_next_node :is_either_of_the_following?, for_response: ""
      end
    end
  end

  context "question: is_either_of_the_following?" do
    setup do
      testing_node :is_either_of_the_following?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support",
                    db_how_long_abroad?: "permanent",
                    is_how_long_abroad?: "is_under_a_year_other",
                    is_claiming_benefits?: ""
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_abroad_for_treatment? for any response" do
        assert_next_node :is_abroad_for_treatment?, for_response: "too_ill_to_work"
      end

      should "have a next node of is_any_of_the_following_apply? for an empty response" do
        assert_next_node :is_any_of_the_following_apply?, for_response: ""
      end
    end
  end

  context "question: is_abroad_for_treatment?" do
    setup do
      testing_node :is_abroad_for_treatment?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support",
                    db_how_long_abroad?: "permanent",
                    is_how_long_abroad?: "is_under_a_year_other",
                    is_claiming_benefits?: "",
                    is_either_of_the_following?: "too_ill_to_work"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_abroad_for_treatment_outcome for a 'yes' response" do
        assert_next_node :is_abroad_for_treatment_outcome, for_response: "yes"
      end

      should "have a next node of is_work_or_sick_pay? for a 'no' response" do
        assert_next_node :is_work_or_sick_pay?, for_response: "no"
      end
    end
  end

  context "question: is_work_or_sick_pay?" do
    setup do
      testing_node :is_work_or_sick_pay?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support",
                    db_how_long_abroad?: "permanent",
                    is_how_long_abroad?: "is_under_a_year_other",
                    is_claiming_benefits?: "",
                    is_either_of_the_following?: "too_ill_to_work",
                    is_abroad_for_treatment?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_abroad_for_treatment_outcome for any response" do
        assert_next_node :is_abroad_for_treatment_outcome, for_response: "364_days"
      end

      should "have a next node of is_not_eligible_outcome for an empty response" do
        assert_next_node :is_not_eligible_outcome, for_response: ""
      end
    end
  end

  context "question: is_any_of_the_following_apply?" do
    setup do
      testing_node :is_any_of_the_following_apply?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support",
                    db_how_long_abroad?: "permanent",
                    is_how_long_abroad?: "is_under_a_year_other",
                    is_claiming_benefits?: "",
                    is_either_of_the_following?: ""
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_not_eligible_outcome for any response" do
        assert_next_node :is_not_eligible_outcome, for_response: "trades_dispute"
      end

      should "have a next node of is_abroad_for_treatment_outcome for an empty response" do
        assert_next_node :is_abroad_for_treatment_outcome, for_response: ""
      end
    end
  end

  context "question: tax_credits_how_long_abroad?" do
    setup do
      testing_node :tax_credits_how_long_abroad?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of tax_credits_why_going_abroad? for a 'tax_credits_up_to_a_year' response" do
        assert_next_node :tax_credits_why_going_abroad?, for_response: "tax_credits_up_to_a_year"
      end

      should "have a next node of tax_credits_children? for a 'tax_credits_more_than_a_year' response" do
        assert_next_node :tax_credits_children?, for_response: "tax_credits_more_than_a_year"
      end
    end
  end

  context "question: esa_how_long_abroad?" do
    setup do
      testing_node :esa_how_long_abroad?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "esa"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of esa_going_abroad_under_a_year_medical_outcome for a 'esa_under_a_year_medical' response if going_abroad" do
        assert_next_node :esa_going_abroad_under_a_year_medical_outcome, for_response: "esa_under_a_year_medical"
      end

      should "have a next node of esa_going_abroad_under_a_year_other_outcome for a 'esa_under_a_year_other' response if going_abroad" do
        assert_next_node :esa_going_abroad_under_a_year_other_outcome, for_response: "esa_under_a_year_other"
      end

      should "have a next node of esa_already_abroad_under_a_year_medical_outcome for a 'esa_under_a_year_medical' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :esa_already_abroad_under_a_year_medical_outcome, for_response: "esa_under_a_year_medical"
      end

      should "have a next node of esa_already_abroad_under_a_year_other_outcome for a 'esa_under_a_year_other' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :esa_already_abroad_under_a_year_other_outcome, for_response: "esa_under_a_year_other"
      end

      should "have a next node of which_country? for a 'esa_more_than_a_year' response" do
        assert_next_node :which_country?, for_response: "esa_more_than_a_year"
      end
    end
  end

  context "question: db_how_long_abroad?" do
    setup do
      testing_node :db_how_long_abroad?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "disability_benefits"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of which_country? for a 'permanent' response" do
        assert_next_node :which_country?, for_response: "permanent"
      end

      should "have a next node of db_going_abroad_temporary_outcome for a 'temporary' response if going_abroad" do
        assert_next_node :db_going_abroad_temporary_outcome, for_response: "temporary"
      end

      should "have a next node of db_already_abroad_temporary_outcome for a 'temporary' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad"
        assert_next_node :db_already_abroad_temporary_outcome, for_response: "temporary"
      end
    end
  end

  context "question: is_how_long_abroad?" do
    setup do
      testing_node :is_how_long_abroad?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "income_support"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of is_under_a_year_medical_outcome for a 'is_under_a_year_medical' response" do
        assert_next_node :is_under_a_year_medical_outcome, for_response: "is_under_a_year_medical"
      end

      should "have a next node of is_claiming_benefits? for a 'is_under_a_year_other' response" do
        assert_next_node :is_claiming_benefits?, for_response: "is_under_a_year_other"
      end

      should "have a next node of is_more_than_a_year_outcome for a 'is_more_than_a_year' response" do
        assert_next_node :is_more_than_a_year_outcome, for_response: "is_more_than_a_year"
      end
    end
  end

  context "question: worked_in_eea_or_switzerland?" do
    setup do
      testing_node :worked_in_eea_or_switzerland?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "jsa",
                    which_country?: "liechtenstein"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of esa_going_abroad_eea_outcome for a 'before_jan_2021' response if benefit is esa and going_abroad" do
        add_responses which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_going_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of esa_already_abroad_eea_outcome for a 'before_jan_2021' response if benefit is esa and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_already_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of db_going_abroad_eea_outcome for a 'before_jan_2021' response going_abroad" do
        add_responses which_benefit?: "disability_benefits",
                      db_how_long_abroad?: "permanent"
        assert_next_node :db_going_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of db_already_abroad_eea_outcome for a 'before_jan_2021' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_benefit?: "disability_benefits",
                      db_how_long_abroad?: "permanent"
        assert_next_node :db_already_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      # TODO: Do we need to cycle through the different benefits for the following tests?
      should "have a next node of jsa_eea_going_abroad_maybe_outcome for a 'before_jan_2021' response if benefit is jsa" do
        assert_next_node :jsa_eea_going_abroad_maybe_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of parents_lived_in_eea_or_switzerland? for a 'after_jan_2021' response if benefit is jsa" do
        assert_next_node :parents_lived_in_eea_or_switzerland?, for_response: "after_jan_2021"
      end

      should "have a next node of parents_lived_in_eea_or_switzerland? for a 'no' response if benefit is jsa" do
        assert_next_node :parents_lived_in_eea_or_switzerland?, for_response: "no"
      end
    end
  end

  context "question: parents_lived_in_eea_or_switzerland?" do
    setup do
      testing_node :parents_lived_in_eea_or_switzerland?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "jsa",
                    which_country?: "liechtenstein",
                    worked_in_eea_or_switzerland?: "no"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of jsa_eea_going_abroad_maybe_outcome for a 'before_jan_2021' response if benefit is jsa" do
        assert_next_node :jsa_eea_going_abroad_maybe_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of esa_going_abroad_eea_outcome for a 'before_jan_2021' response if benefit is esa and going_abroad" do
        add_responses which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_going_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of esa_already_abroad_eea_outcome for a 'before_jan_2021' response if benefit is esa and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_already_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of db_going_abroad_eea_outcome for a 'before_jan_2021' response if going_abroad" do
        add_responses which_benefit?: "disability_benefits",
                      db_how_long_abroad?: "permanent"
        assert_next_node :db_going_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of db_already_abroad_eea_outcome for a 'before_jan_2021' response if already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_benefit?: "disability_benefits",
                      db_how_long_abroad?: "permanent"
        assert_next_node :db_already_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      %w[after_jan_2021 no].each do |response|
        should "have a next node of jsa_not_entitled_outcome for a '#{response}' response if benefit is jsa" do
          assert_next_node :jsa_not_entitled_outcome, for_response: response
        end

        should "have a next node of esa_going_abroad_other_outcome for a '#{response}' response if benefit is esa and going_abroad" do
          add_responses which_benefit?: "esa",
                        esa_how_long_abroad?: "esa_more_than_a_year"
          assert_next_node :esa_going_abroad_other_outcome, for_response: response
        end

        should "have a next node of esa_already_abroad_other_outcome for a '#{response}' response if benefit is esa and already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad",
                        which_benefit?: "esa",
                        esa_how_long_abroad?: "esa_more_than_a_year"
          assert_next_node :esa_already_abroad_other_outcome, for_response: response
        end

        should "have a next node of db_going_abroad_other_outcome for a '#{response}' response if going_abroad" do
          add_responses which_benefit?: "disability_benefits",
                        db_how_long_abroad?: "permanent"
          assert_next_node :db_going_abroad_other_outcome, for_response: response
        end

        should "have a next node of db_already_abroad_other_outcome for a '#{response}' response if already_abroad" do
          add_responses going_or_already_abroad?: "already_abroad",
                        which_benefit?: "disability_benefits",
                        db_how_long_abroad?: "permanent"
          assert_next_node :db_already_abroad_other_outcome, for_response: response
        end
      end
    end
  end

  context "question: is_british_or_irish?" do
    setup do
      testing_node :is_british_or_irish?
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "jsa",
                    which_country?: "ireland"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of jsa_ireland_outcome for a 'yes' response if benefit is jsa" do
        assert_next_node :jsa_ireland_outcome, for_response: "yes"
      end

      should "have a next node of esa_going_abroad_eea_outcome for a 'yes' response if benefit is esa and going_abroad" do
        add_responses which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_going_abroad_eea_outcome, for_response: "yes"
      end

      should "have a next node of esa_already_abroad_eea_outcome for a 'yes' response if benefit is esa and already_abroad" do
        add_responses going_or_already_abroad?: "already_abroad",
                      which_benefit?: "esa",
                      esa_how_long_abroad?: "esa_more_than_a_year"
        assert_next_node :esa_already_abroad_eea_outcome, for_response: "yes"
      end

      should "have a next node of db_going_abroad_eea_outcome for a 'yes' response" do
        add_responses which_benefit?: "disability_benefits",
                      db_how_long_abroad?: "permanent"
        assert_next_node :db_going_abroad_eea_outcome, for_response: "before_jan_2021"
      end

      should "have a next node of worked_in_eea_or_switzerland? for a 'no' response" do
        assert_next_node :worked_in_eea_or_switzerland?, for_response: "no"
      end
    end
  end

  context "outcome: bb_already_abroad_ss_outcome" do
    setup do
      testing_node :bb_already_abroad_ss_outcome
      add_responses going_or_already_abroad?: "already_abroad",
                    which_benefit?: "bereavement_benefits"
    end

    should "render widowed parents guidance if country is Bermuda" do
      add_responses which_country?: "bermuda"
      assert_rendered_outcome text: "You might be able to get Widowed Parent’s Allowance."
    end

    should "render widowed parents guidance if country is Mauritius" do
      add_responses which_country?: "mauritius"
      assert_rendered_outcome text: "You might be able to get Widowed Parent’s Allowance."
    end

    should "render bereavement support guidance if country is Canada" do
      add_responses which_country?: "canada"
      assert_rendered_outcome text: "You might be able to get Bereavement Support Payment"
    end

    should "render general guidance for countries in social security country with bereavement benefits" do
      add_responses which_country?: "north-macedonia"
      assert_rendered_outcome text: "You might be able to get Bereavement Support Payment or Widowed Parent’s Allowance."
    end
  end

  context "outcome: bb_going_abroad_ss_outcome" do
    setup do
      testing_node :bb_going_abroad_ss_outcome
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "bereavement_benefits"
    end

    should "render widowed parents guidance if country is Bermuda" do
      add_responses which_country?: "bermuda"
      assert_rendered_outcome text: "ou may be able to export Widowed Parent’s Allowance"
    end

    should "render widowed parents guidance if country is Mauritius" do
      add_responses which_country?: "mauritius"
      assert_rendered_outcome text: "ou may be able to export Widowed Parent’s Allowance"
    end

    should "render bereavement support guidance if country is Canada" do
      add_responses which_country?: "canada"
      assert_rendered_outcome text: "You may be able to export Bereavement Support Payment"
    end

    should "render general guidance for countries in social security country with bereavement benefits" do
      add_responses which_country?: "north-macedonia"
      assert_rendered_outcome text: "You may be able to export bereavement benefits"
    end
  end

  context "outcome: tax_credits_cross_border_worker_outcome" do
    setup do
      testing_node :tax_credits_cross_border_worker_outcome
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "cross_border_worker"
    end

    should "render tax credits UK helpline number if going_abroad" do
      assert_rendered_outcome text: "Telephone: 0345 300 3900"
    end

    should "render tax credits outside UK helpline number if already_abroad" do
      add_responses going_or_already_abroad?: "already_abroad"
      assert_rendered_outcome text: "From outside the UK: +44 2890 538 192"
    end
  end

  context "outcome: tax_credits_crown_servant_outcome" do
    setup do
      testing_node :tax_credits_crown_servant_outcome
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "crown_servant"
    end

    should "render tax credits UK helpline number if going_abroad" do
      assert_rendered_outcome text: "Telephone: 0345 300 3900"
    end

    should "render tax credits outside UK helpline number if already_abroad" do
      add_responses going_or_already_abroad?: "already_abroad"
      assert_rendered_outcome text: "From outside the UK: +44 2890 538 192"
    end
  end

  context "outcome: tax_credits_holiday_outcome" do
    setup do
      testing_node :tax_credits_holiday_outcome
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above",
                    tax_credits_how_long_abroad?: "tax_credits_up_to_a_year",
                    tax_credits_why_going_abroad?: "tax_credits_holiday"
    end

    should "render going abroad guidance if going_abroad" do
      assert_rendered_outcome text: "You may be able to carry on getting tax credits for up to 8 weeks."
    end

    should "render already abroad if already_abroad" do
      add_responses going_or_already_abroad?: "already_abroad"
      assert_rendered_outcome text: "You can carry on getting tax credits for up to 8 weeks after leaving the UK if you were already receiving them before you left."
    end
  end

  context "outcome: tax_credits_medical_death_outcome" do
    setup do
      testing_node :tax_credits_medical_death_outcome
      add_responses going_or_already_abroad?: "going_abroad",
                    which_benefit?: "tax_credits",
                    eligible_for_tax_credits?: "none_of_the_above",
                    tax_credits_how_long_abroad?: "tax_credits_up_to_a_year",
                    tax_credits_why_going_abroad?: "tax_credits_medical_treatment"
    end

    should "render going abroad guidance if going_abroad" do
      assert_rendered_outcome text: "You may be able to carry on getting tax credits for up to 12 weeks."
    end

    should "render already abroad if already_abroad" do
      add_responses going_or_already_abroad?: "already_abroad"
      assert_rendered_outcome text: "You can carry on getting tax credits for up to 12 weeks after leaving the UK if you were already receiving them before you left."
    end
  end
end
