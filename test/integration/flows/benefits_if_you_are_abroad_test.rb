# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BenefitsIfYouAreAbroadTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'benefits-if-you-are-abroad'
  end

  # Q1
  should "ask have you told jobcentre plus?" do
    assert_current_node :have_you_told_jobcentre_plus
  end

  should "be answer_1 for no" do
    add_response :no
    assert_current_node :answer_1
  end

  context "yes to 'have you told jobcentre plus?'" do
    setup do
      add_response :yes
    end
    # Q2
    should "ask 'have you paid ni in the uk?' for yes" do
      assert_current_node :have_you_paid_ni_in_the_uk
    end
  
    should "be answer 2 for no" do
      add_response :no
      assert_current_node :answer_2
    end

    context "yes to 'have you paid ni in the uk?'" do
      setup do
        add_response :yes
      end

      #Q3
      should "ask 'certain countries or specific benefits?' for yes" do
        assert_current_node :certain_countries_or_specific_benefits
      end

      context "certain countries for certain countries or specific benefits?" do
      
        setup do
          add_response :certain_countries
        end
        
        # Q4
        should "ask 'are you moving to?'" do
          assert_current_node :are_you_moving_to_q4
        end
        
        context "eea or switzerland for 'are you moving to:'" do
          should "be answer 3 for eea or switzerland" do
            add_response :eea_or_switzerland
            assert_current_node :answer_3
          end  
        end

        context "gibraltar for 'are you moving to:'" do
          should "be answer 4 for gibraltar" do
            add_response :gibraltar
            assert_current_node :answer_4
          end
        end

        context "other listed for 'are you moving to:'" do
          should "be answer 5 for other listed" do
            add_response :other_listed
            assert_current_node :answer_5
          end
        end

        context "none of the above for 'are you moving to:'" do
          should "be answer 6 for none of the above" do
            add_response :none_of_the_above
            assert_current_node :answer_6
          end
        end
      
      end
      
      context "specific benefits for 'certain countries or specific benefits?'" do
        setup do
          add_response :specific_benefits
        end
        
        
        # Q5
        should "ask 'which benefit would you like to claim?' for specific benefits" do
          assert_current_node :which_benefit_would_you_like_to_claim
        end

        should "be answer 7 for pension" do
          add_response :pension
          assert_current_node :answer_7
        end

        context "jsa for 'which benefit would you like to claim?'" do
          setup do
            add_response :jsa
          end
          
          # Q6
          should "ask 'are you moving to:'" do
            assert_current_node :are_you_moving_to_q6
          end
          
          context "eea, switzerland, gibraltar for 'are you moving to:'" do
            should "be answer 8" do
              add_response :eea_switzerland_gibraltar
              assert_current_node :answer_8
            end
          end
          
          context "jersey, etc. for 'are you moving to:'" do
            should "be answer 9" do
              add_response :jersey_etc
              assert_current_node :answer_9
            end            
          end
          
          context "none of the above for 'are you moving to:'" do
            should "be answer 9" do
              add_response :none_of_the_above
              assert_current_node :answer_10
            end           
          end
          
        end

        context "wfp for 'which benefit would you like to claim?'" do
          setup do
            add_response :wfp
          end
          
          #Q7
          should "ask 'are you moving to:'" do
            assert_current_node :are_you_moving_to_q7
          end
          
          context "eea switzerland gibraltar for 'are you moving to:'" do
            
            setup do
              add_response :eea_switzerland_gibraltar
            end
            
            # Q8
            should "ask 'do you already qualify for wfp payments in the uk?'" do
              assert_current_node :already_qualify_for_wfp_in_the_uk
            end
            
            context "yes for 'do you already qualify for wfp payments in the uk?'" do
              should "be answer 12" do
                add_response :yes
                assert_current_node :answer_12
              end
            end
            
            context "no for 'do you already qualify for wfp payments in the uk?'" do
              should "should be answer 11" do
                add_response :no
                assert_current_node :answer_11
              end
            end
          end
          
          context "other for 'are you moving to:'" do
            should "be answer 11" do
              add_response :none
              assert_current_node :answer_11
            end
          end
          
        end

        context "maternity for 'which benefit would you like to claim?'" do
          setup do
            add_response :maternity
          end
          
          # Q9
          should "ask 'are you moving to a country:'" do
            assert_current_node :are_you_moving_to_a_country_q9
          end

          context "EEA for 'are you moving to a country:'" do
            setup do
              add_response :eea
            end

            # Q10
            should "ask 'Are you working for a UK employer?'" do
              assert_current_node :uk_employer
            end

            context "no for 'working for a UK employer'" do
              should "be answer 13" do
                add_response :no
                assert_current_node :answer_13
              end
            end

            context "yes for 'working for a UK employer'" do
              setup do
                add_response :yes
              end

              # Q11
              should "ask 'Are you eligibile for Statutory Maternity Pay?'" do
                assert_current_node :eligible_for_maternity_pay
              end

              context "yes for 'eligibile for Statutory Maternity Pay'" do
                should "be answer 14" do
                  add_response :yes
                  assert_current_node :answer_14
                end
              end

              context "no for 'eligibile for Statutory Maternity Pay'" do
                should "be answer 13" do
                  add_response :no
                  assert_current_node :answer_13
                end
              end
            end
          end

          context "not EEA for 'are you moving to a country:'" do
            setup do
              add_response :not_eea
            end

            # Q12
            should "ask 'employer paying NI contributions for you?'" do
              assert_current_node :employer_paying_ni
            end

            context "yes for 'employer paying NI contributions'" do
              should "ask 'eligible for SMP?'" do
                add_response :yes
                assert_current_node :eligible_for_maternity_pay
              end
            end

            context "no for 'employer paying NI contributions'" do
              should "be answer 15" do
                add_response :no
                assert_current_node :answer_15
              end
            end
          end
        end

        context "child benefits for 'which benefit would you like to claim?'" do
          setup do
            add_response :child_benefits
          end

          # Q13
          should "ask 'Are you moving to?'" do
            assert_current_node :moving_to
          end
          
          context "answers to 'Are you moving to:'" do
            should "be answer 16a" do
              add_response :bosnia_croatia_kosova
              assert_current_node :answer_16a
            end
            should "be answer 16b" do
              add_response :barbados_canada_israel
              assert_current_node :answer_16b
            end
            should "be answer 16c" do
              add_response :jamaica_turkey_usa
              assert_current_node :answer_16c
            end
          end
          
          context "EEA or Switzerland for 'Are you moing to:'" do
            setup do
              add_response :eea_or_switzerland
            end
            
            # Q14
            should "ask 'Paying NICs and receiving UK benefits?'" do
              assert_current_node :paying_nics_and_receiving_uk_benefits
            end
            
            context "yes to 'Paying NICs and receiving UK benefits?'" do
              should "be answer 17" do
                add_response :yes
                assert_current_node :answer_17
              end
            end
            context "no to 'Paying NICs and receiving UK benefits?'" do
              should "be answer 18" do
                add_response :no
                assert_current_node :answer_18
              end
            end
          end
          
          context "other for 'Are you moving to:'" do
            should "be answer 16" do
              add_response :other
              assert_current_node :answer_18
            end
          end
          
        end

        context "ssp for 'which benefit would you like to claim?'" do
          setup do
            add_response :ssp
          end

          # Q15
          should "ask 'Are you moving to a country?'" do
            assert_current_node :are_you_moving_to_a_country_q15
          end
          
          context "in EEA to 'Are you moving to a country?'" do

            setup do
              add_response :in_eea
            end
            
            # Q16
            should "ask 'Working for a UK employer?'" do
              assert_current_node :working_for_a_uk_employer
            end
            
            context "yes to 'Working for a UK employer?'" do
              should "be answer 19" do
                add_response :yes
                assert_current_node :answer_19
              end
            end
            context "no to 'Working for a UK employer?'" do
              should "be answer 20" do
                add_response :no
                assert_current_node :answer_20
              end
            end
            
          end
          
          context "outside EEA to 'Are you moving to a country?" do
            setup do
              add_response :outside_eea
            end
            
            # Q17
            should "ask 'Employer paying UK NICs?'" do
              assert_current_node :employer_paying_uk_nics
            end
            
            context "yes to 'Employer paying UK NICs?'" do
              should "be answer 19" do
                add_response :yes
                assert_current_node :answer_19
              end
            end
            
            context "no to 'Employer paying UK NICs?'" do
              should "be answer 20" do
                add_response :no
                assert_current_node :answer_20
              end
            end
          end
          
        end

        context "tax credits for 'which benefit would you like to claim?'" do
          setup do
            add_response :tax_credits
          end

          # Q18
          should "ask 'Are you claiming tax credits or eligible?'" do
            assert_current_node :claiming_tax_credits_or_eligible
          end

          context "no for 'claiming tax credits'" do
            should "get answer 21" do
              add_response :no
              assert_current_node :answer_21
            end
          end

          context "yes for 'claiming tax credits'" do
            setup do
              add_response :yes
            end

            # Q19
            should "ask 'are you or your partner?'" do
              assert_current_node :you_or_partner
            end

            context "for crown servant" do
              should "get answer 22" do
                add_response :crown_servant
                assert_current_node :answer_22
              end
            end

            context "for cross border worker" do
              should "get answer 23" do
                add_response :cross_border_worker
                assert_current_node :answer_23
              end
            end

            context "for neither" do
              setup do
                add_response :neither
              end

              # Q23
              should "ask 'are going abroad for?'" do
                assert_current_node :going_abroad_for
              end

              context "greater than a year" do
                setup do
                  add_response :greater_than_a_year
                end

                # Q20
                should "ask 'do you have a child?'" do
                  assert_current_node :got_a_child
                end

                context "no child" do
                  should "get answer 21" do
                    add_response :no
                    assert_current_node :answer_21
                  end
                end

                context "has child" do
                  setup do
                    add_response :yes
                  end

                  # Q21
                  should "ask 'Where are you and your child living in or moving to?'" do
                    assert_current_node :moving_to_eea
                  end

                  context "none to 'Where are you and your child living in or moving to?'" do
                    should "get answer 21" do
                      add_response :none
                      assert_current_node :answer_21
                    end
                  end

                  context "'An EEA country or Switzerland' to 'Where are you and your child living in or moving to?'" do
                    setup do
                      add_response :eea_or_switzerland
                    end

                    # Q22
                    should "ask 'are you claiming benefit or pension?'" do
                      assert_current_node :claiming_benefit_or_pension
                    end

                    context "no to 'claiming benefit or pension'" do
                      should "get answer_21" do
                        add_response :no
                        assert_current_node :answer_21
                      end
                    end

                    context "yes to 'claiming benefit or pension'" do
                      should "get answer_24" do
                        add_response :yes
                        assert_current_node :answer_24
                      end
                    end
                  end
                end
              end

              context "less than a year" do
                setup do
                  add_response :less_than_a_year
                end
                
                # Q24
                should "ask 'are you going abroad?'" do
                  assert_current_node :going_abroad
                end

                context "for holiday" do
                  should "get answer 25" do
                    add_response :holiday
                    assert_current_node :answer_25
                  end
                end

                context "for medical treatment" do
                  should "get answer 26" do
                    add_response :medical_treatment
                    assert_current_node :answer_26
                  end
                end
                
                context "'because of the death of your partner or close family member'" do
                  should "get answer 26" do
                    add_response :death
                    assert_current_node :answer_26
                  end
                end
              end
            end
          end
        end

        context "esa for 'which benefit would you like to claim?'" do
          setup do
            add_response :esa
          end

          # Q25
          should "ask 'Are you claiming ESA and going abroad for?'" do
            assert_current_node :claiming_esa_abroad_for
          end
          
          context "less than a year and medical treatment to 'Are you claiming ESA and going abroad for?'" do
            should "be answer 27" do
              add_response :less_than_year_and_medical_treatment
              assert_current_node :answer_27
            end
          end
          
          context "less than a year and different reason to 'Are you claiming ESA and going abroad for?'" do
            should "be answer 28" do
              add_response :less_than_year_and_different_reason
              assert_current_node :answer_28
            end
          end
          
          context "greater than a year or permanently to 'Are you claiming ESA and going abroad for?'" do
            setup do
              add_response :greater_than_year_or_permanently
            end
            
            # Q26
            should "ask 'Are you moving to:'" do
              assert_current_node :are_you_moving_to_q26
            end
            
            context "EEA, Switzerland, Gibraltar to 'Are you moving to:'" do
              should "be answer 29" do
                add_response :eea_switzerland_gibraltar
                assert_current_node :answer_29
              end
            end

            context "None of the above 'Are you moving to:'" do
              should "be answer 30" do
                add_response :none
                assert_current_node :answer_30
              end
            end
            
          end
        end

        context "industrial injuries for 'which benefit would you like to claim?'" do
          setup do
            add_response :industrial_injuries
          end

          # Q27
          should "ask 'claiming Disablement Benefit before moving overseas?'" do
            assert_current_node :claiming_iidb
          end
          
          context "no to 'claiming Disablement Benefit before moving overseas?'" do
            should "be answer 31" do
              add_response :no
              assert_current_node :answer_31
            end
          end
          
          context "yes to 'claiming Disablement Benefit before moving overseas?'" do
            setup do
              add_response :yes
            end
            
            # Q28
            should "ask 'Which country are you living in or moving to?'" do
              assert_current_node :moving_to_eea2
            end
            
            context "'in_eea' to 'Which country are you living in or moving to?'" do
              should "be answer 32" do
                add_response :in_eea
                assert_current_node :answer_32
              end
            end
            
            context "'outside_eea' to 'Which country are you living in or moving to?'" do
              should "be answer 33" do
                add_response :outside_eea
                assert_current_node :answer_33
              end
            end
          end
        end

        context "disability for 'which benefit would you like to claim?'" do
          setup do
            add_response :disability
          end

          # Q29
          should "ask 'Are you currently getting any of the following?'" do
            assert_current_node :getting_any_allowances
          end
          
          context "no to 'Are you currently getting any of the following?'" do
            should "be answer 34" do
              add_response :no
              assert_current_node :answer_34
            end
          end
          
          context "yes to 'Are you currently getting any of the following?'" do
            setup do
              add_response :yes
            end
            
            # Q30
            should "ask 'Going abroad?'" do
              assert_current_node :going_abroad_q30
            end
            
            context "temporarily to 'Going abroad?'" do
              should "be answer 35" do
                add_response :temporarily
                assert_current_node :answer_35
              end
            end
            context "permanently to 'Going abroad?'" do
              setup do
                add_response :permanently
              end
              
              # Q31
              should "ask 'Moving to:'" do
                assert_current_node :moving_to_q31
              end
              
              context "none to 'Moving to:'" do
                should "be answer 34" do
                  add_response :none
                  assert_current_node :answer_34
                end
              end
              
              context "EEA, Switzerland, Gibraltar to 'Moving to:'" do
                setup do
                  add_response :eea_switzerland_gibraltar
                end
                
                # Q32
                should "ask 'Do you or a family member pay UK NICs?'" do
                  assert_current_node :do_you_or_family_pay_uk_nic
                end
                
                context "no to 'Do you or a family member pay UK NICs?'" do
                  should "be answer 34" do
                    add_response :no
                    assert_current_node :answer_34
                  end
                end
                context "yes to 'Do you or a family member pay UK NICs?'" do
                  setup do
                    add_response :yes
                  end
                  
                  # Q33
                  should "ask 'Paid enough to claim sickness benefit?'" do
                    assert_current_node :enough_to_claim_sickness_benefit
                  end
                  
                  context "yes to 'Paid enough to claim sickness benefit?'" do
                    setup do
                      add_response :yes
                    end
                    
                    # Q34
                    should "ask 'Getting SSP, IIB, ESA or bereavment?'" do
                      assert_current_node :getting_ssp_iib_esa_or_bereavment
                    end
                    
                    context "yes to 'Getting SSP, IIB, ESA or bereavment?'" do
                      should "be answer 35b" do
                        add_response :yes
                        assert_current_node :answer_35b
                      end
                    end
                    
                    context "no to 'Getting SSP, IIB, ESA or bereavment?'" do
                      should "be answer 34" do
                        add_response :no
                        assert_current_node :answer_34
                      end
                    end                    
                  end
                  
                end
              end
            end
          end
        end

        context "bereavement for 'which benefit would you like to claim?'" do
          setup do
            add_response :bereavement
          end

          # Q35
          should "ask 'Are you eligible for the following?'" do
            assert_current_node :eligible_for_the_following
          end

          context "no to 'are you eligible'" do
            should "get answer 36" do
              add_response :no
              assert_current_node :answer_36
            end
          end

          context "yes to 'are you eligible'" do
            setup do
              add_response :yes
            end

            # Q36
            should "ask 'are you moving to?'" do
              assert_current_node :are_you_moving_to_q36
            end

            context "eea to 'are you moving to'" do
              should "get answer 37" do
                add_response :eea_switzerland_gibraltar
                assert_current_node :answer_37
              end
            end

            context "none to 'are you moving to'" do
              should "get answer 38" do
                add_response :none
                assert_current_node :answer_38
              end
            end
          end
        end
      end
    end
  end
end
