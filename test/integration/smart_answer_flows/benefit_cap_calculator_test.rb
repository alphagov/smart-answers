require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/benefit-cap-calculator"

class BenefitCapCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::BenefitCapCalculatorFlow
  end

  context "Benefit cap calculator" do
    setup do
      WebMock.stub_request(:get, "#{Plek.new.find('imminence')}/areas/IG6%202BA.json").
        to_return(body: File.open(fixture_file('imminence/london.json')))
      WebMock.stub_request(:get, "#{Plek.new.find('imminence')}/areas/B1%201PW.json").
        to_return(body: File.open(fixture_file('imminence/national.json')))
    end
    context "default flow" do
      setup { add_response :default }
      #Q1 Receiving Housing Benefit
      should "ask do you receive housing benefit" do
        assert_current_node :receive_housing_benefit?
      end

      context "answer yes" do
        setup { add_response :yes }

        #Q2 Qualify for working tax credit
        should "ask if qualify for working tax credit" do
          assert_current_node :working_tax_credit?
        end

        context "answer yes" do
          setup { add_response :yes }

          should "go to Outcome 1" do
            assert_current_node :outcome_not_affected_exemptions
          end
        end # Q2 Qualify for working tax credit at Outcome 1

        ## Not qualify for working tax credit from Q3
        context "answer no" do
          setup { add_response :no }

          #Q3
          should "Ask if household receiving exemption benefits" do
            assert_current_node :receiving_exemption_benefits?
          end

          context "answer yes" do
            setup { add_response :yes }

            should "go to outcome 1" do
              assert_current_node :outcome_not_affected_exemptions
            end
          end # Q3 receiving benefits end at Outcome 1

          # not receiving exemption benefits from Q3
          context "answer no" do
            setup { add_response :no }

            #Q4
            should "ask if household receiving other benefits" do
              assert_current_node :receiving_non_exemption_benefits?
            end

            context "answer receiving additional benefits" do
              setup { add_response 'guardian,sda' }

              #Q5f
              should "ask how much for guardian allowance benefit" do
                assert_state_variable :benefit_types, [:sda]
                assert_current_node :guardian_amount?
                assert_state_variable :total_benefits, 0
              end

              context "answer guardian allowance amount" do
                setup { add_response "300" }

                #Q5k
                should "ask how much for severe disability allowance" do
                  assert_state_variable :benefit_types, []
                  assert_current_node :sda_amount?
                  assert_state_variable :total_benefits, 300
                end

                context "answer sda amount" do
                  setup { add_response "300" }

                  #Q5p
                  should "ask how much for housing benefit" do
                    assert_state_variable :benefit_types, []
                    assert_state_variable :total_benefits, 600
                    assert_current_node :housing_benefit_amount?
                  end

                  context "answer housing benefit amount" do
                    setup { add_response "300" }

                    #Q6
                    should "ask whether single, living with couple or lone parent" do
                      assert_current_node :single_couple_lone_parent?
                    end

                    context "answer single above cap" do
                      setup { add_response "single" }

                      should "go to outcome 3" do
                        assert_current_node :outcome_affected_greater_than_cap
                      end
                    end #Q6 single greater than cap, at Outcome 3
                  end #Q5p how much for housing benefit
                end #Q5k how much for severe disablity allowance
              end #Q5f how much for guardian allowance benefit
            end #Q4 receiving additional benefits, above cap

            context "answer receiving additional benefits" do
              setup { add_response 'esa,maternity' }

              should "ask ask how much for esa benefit" do
                assert_state_variable :benefit_types, [:maternity]
                assert_current_node :esa_amount?
              end

              context "answer esa amount" do
                setup { add_response "10" }

                should "ask how much for maternity benefits" do
                  assert_state_variable :benefit_types, []
                  assert_current_node :maternity_amount?
                end

                context "answer maternity amount" do
                  setup { add_response "10" }

                  should "ask how much for housing benefits" do
                    assert_state_variable :benefit_types, []
                    assert_current_node :housing_benefit_amount?
                  end

                  context "answer housing benefit amount" do
                    setup { add_response "10" }

                    should "ask if single, couple or lone parent" do
                      assert_current_node :single_couple_lone_parent?
                    end

                    context "answer lone parent" do
                      setup { add_response 'parent' }

                      should "go to outcome" do
                        assert_current_node :outcome_not_affected_less_than_cap
                      end
                    end #Q6 lone parent, under cap, at Outcome 4
                  end #Q5p how much for housing, under cap
                end #Q5j how much for maternity, under cap
              end #Q5e how much for esa, under cap
            end #Q4 receiving additional benefits, under cap

            # not receiving additional benefits from Q4
            context "no additional benefits selected" do
              setup { add_response 'none' }

              should "ask for housing benefit amount" do
                assert_current_node :housing_benefit_amount?
              end

              context "answer housing benefit amount" do
                setup { add_response "10" }

                should "ask if single, couple or lone parent" do
                  assert_current_node :single_couple_lone_parent?
                end

                context "answer lone parent" do
                  setup { add_response 'parent' }

                  should "go to outcome" do
                    assert_current_node :outcome_not_affected_less_than_cap
                  end
                end #Q6 lone parent, under cap, at Outcome 4
              end #Q5p how much for housing, under cap
            end #Q4 no additional benefits at Outcome 5
          end #Q3 not receiving benefits
        end # Q2 not qualify for working tax credit
      end # Q1 Receiving housing benefit

      # Not receiving housing benefit
      context "answer no" do
        setup { add_response :no }

        should "go to Outcome 1" do
          assert_current_node :outcome_not_affected_no_housing_benefit
        end
      end # Q1 not receving housing benefit at Outcome 2

      context "housing benefit less than 0.5" do
        should "show :outcome_affected_greater_than_cap outcome" do
          add_response :yes
          add_response :no
          add_response :no
          add_response :child_benefit
          add_response "100"
          add_response "400"
          add_response :single
          assert_current_node :outcome_affected_greater_than_cap
        end
      end
    end # Benefit cap calculator default flow
    context "future flow" do
      setup do
        add_response :future
      end
      #Q1 Receiving Housing Benefit
      should "ask do you receive housing benefit" do
        assert_current_node :receive_housing_benefit?
      end

      context "answer yes" do
        setup { add_response :yes }

        #Q2 Qualify for working tax credit
        should "ask if qualify for working tax credit" do
          assert_current_node :working_tax_credit?
        end

        context "answer yes" do
          setup { add_response :yes }

          should "go to Outcome 1" do
            assert_current_node :outcome_not_affected_exemptions_future
          end
        end # Q2 Qualify for working tax credit at Outcome 1

        ## Not qualify for working tax credit from Q3
        context "answer no" do
          setup { add_response :no }

          #Q3
          should "Ask if household receiving exemption benefits" do
            assert_current_node :receiving_exemption_benefits?
          end

          context "answer yes" do
            setup { add_response :yes }

            should "go to outcome 1" do
              assert_current_node :outcome_not_affected_exemptions_future
            end
          end # Q3 receiving benefits end at Outcome 1

          # not receiving exemption benefits from Q3
          context "answer no" do
            setup { add_response :no }

            #Q4
            should "ask if household receiving other benefits" do
              assert_current_node :receiving_non_exemption_benefits_future?
            end

            context "answer receiving additional benefits" do
              setup { add_response 'bereavement,sda' }

              #Q5f
              should "ask how much for bereavement allowance benefit" do
                assert_state_variable :benefit_types, [:sda]
                assert_current_node :bereavement_amount?
                assert_state_variable :total_benefits, 0
              end

              context "answer bereavement allowance amount" do
                setup { add_response "300" }

                #Q5k
                should "ask how much for severe disability allowance" do
                  assert_state_variable :benefit_types, []
                  assert_current_node :sda_amount?
                  assert_state_variable :total_benefits, 300
                end

                context "answer sda amount" do
                  setup { add_response "300" }

                  #Q5p
                  should "ask how much for housing benefit" do
                    assert_state_variable :benefit_types, []
                    assert_state_variable :total_benefits, 600
                    assert_current_node :housing_benefit_amount?
                  end

                  context "answer housing benefit amount" do
                    setup { add_response "300" }

                    #Q6
                    should "ask whether single, living with couple or lone parent" do
                      assert_current_node :single_couple_lone_parent_future?
                    end

                    context "answer single above cap" do
                      setup { add_response "single" }

                      should "ask for your postcode" do
                        assert_current_node :enter_postcode?
                      end
                      context "enter postcode outside London" do
                        setup { add_response "B1 1PW" }

                        should "go to outcome benefits greater than cap for outside London" do
                          assert_current_node :outcome_affected_greater_than_cap_future_national
                        end
                      end
                      context "enter postcode in Greater London" do
                        setup { add_response "IG6 2BA" }

                        should "go to outcome benefits greater than cap for Greater London" do
                          assert_current_node :outcome_affected_greater_than_cap_future_london
                        end
                      end
                    end #Q6 single greater than cap, at Outcome 3
                  end #Q5p how much for housing benefit
                end #Q5k how much for severe disablity allowance
              end #Q5f how much for bereavement allowance benefit
            end #Q4 receiving additional benefits, above cap

            context "answer receiving additional benefits" do
              setup { add_response 'esa,maternity' }

              should "ask ask how much for esa benefit" do
                assert_state_variable :benefit_types, [:maternity]
                assert_current_node :esa_amount?
              end

              context "answer esa amount" do
                setup { add_response "10" }

                should "ask how much for maternity benefits" do
                  assert_state_variable :benefit_types, []
                  assert_current_node :maternity_amount?
                end

                context "answer maternity amount" do
                  setup { add_response "10" }

                  should "ask how much for housing benefits" do
                    assert_state_variable :benefit_types, []
                    assert_current_node :housing_benefit_amount?
                  end

                  context "answer housing benefit amount" do
                    setup { add_response "10" }

                    should "ask if single, couple or lone parent" do
                      assert_current_node :single_couple_lone_parent_future?
                    end

                    context "answer lone parent" do
                      setup { add_response 'parent' }

                      should "ask for your postcode" do
                        assert_current_node :enter_postcode?
                      end
                      context "enter postcode outside London" do
                        setup { add_response "B1 1PW" }

                        should "go to outcome benefits less than cap for outside London" do
                          assert_current_node :outcome_not_affected_less_than_cap_future_national
                        end
                      end
                      context "enter postcode in Greater London" do
                        setup { add_response "IG6 2BA" }

                        should "go to outcome benefits less than cap for Greater London" do
                          assert_current_node :outcome_not_affected_less_than_cap_future_london
                        end
                      end
                    end #Q6 lone parent, under cap, at Outcome 4
                  end #Q5p how much for housing, under cap
                end #Q5j how much for maternity, under cap
              end #Q5e how much for esa, under cap
            end #Q4 receiving additional benefits, under cap

            # not receiving additional benefits from Q4
            context "no additional benefits selected" do
              setup { add_response 'none' }

              should "ask for housing benefit amount" do
                assert_current_node :housing_benefit_amount?
              end

              context "answer housing benefit amount" do
                setup { add_response "10" }

                should "ask if single, couple or lone parent" do
                  assert_current_node :single_couple_lone_parent_future?
                end

                context "answer lone parent" do
                  setup { add_response 'parent' }

                  should "ask for your postcode" do
                    assert_current_node :enter_postcode?
                  end
                  context "enter postcode outside London" do
                    setup { add_response "B1 1PW" }

                    should "go to outcome benefits less than cap for outside London" do
                      assert_current_node :outcome_not_affected_less_than_cap_future_national
                    end
                  end
                  context "enter postcode in Greater London" do
                    setup { add_response "IG6 2BA" }

                    should "go to outcome benefits less than cap for Greater London" do
                      assert_current_node :outcome_not_affected_less_than_cap_future_london
                    end
                  end
                end #Q6 lone parent, under cap, at Outcome 4
              end #Q5p how much for housing, under cap
            end #Q4 no additional benefits at Outcome 5
          end #Q3 not receiving benefits
        end # Q2 not qualify for working tax credit
      end # Q1 Receiving housing benefit

      # Not receiving housing benefit
      context "answer no" do
        setup { add_response :no }

        should "go to Outcome 1" do
          assert_current_node :outcome_not_affected_no_housing_benefit_future
        end
      end # Q1 not receving housing benefit at Outcome 2
    end # Benefit cap calculator future flow
    context "housing benefit less than 0.5 for default cap" do
      should "show :outcome_affected_greater_than_cap outcome" do
        add_response :default
        add_response :yes
        add_response :no
        add_response :no
        add_response :child_benefit
        add_response "100"
        add_response "400"
        add_response :single
        assert_current_node :outcome_affected_greater_than_cap
      end
    end
    context "housing benefit less than 0.5 for future cap" do
      should "show :outcome_affected_greater_than_cap_future_national outcome" do
        add_response :future
        add_response :yes
        add_response :no
        add_response :no
        add_response :child_benefit
        add_response "100"
        add_response "400"
        add_response :single
        add_response "B1 1PW"
        assert_current_node :outcome_affected_greater_than_cap_future_national
      end
    end
  end
end # BenefitCapCalculatorTest
