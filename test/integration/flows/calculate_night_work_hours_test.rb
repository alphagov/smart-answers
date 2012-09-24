# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateNightWorkHoursTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-night-work-hours'
  end

  should "ask your age" do
    assert_current_node :how_old?
  end

  should "not be old enough if under 18" do
    add_response 'under-18'
    assert_current_node :not_old_enough
  end

  context "when 18 or over" do
    setup do
      add_response '18-or-over'
    end

    should "ask if there are exceptions to the work limits" do
      assert_current_node :exception_to_limits?
    end

    context "there are exceptions to limits" do
      should "investigate specific rules" do
        add_response :yes
        assert_current_node :investigate_specific_rules
      end
    end

    context "no exceptions to limits" do
      setup do
        add_response :no
      end

      should "ask how many night hours worked" do
        assert_current_node :how_many_night_hours_worked?
      end

      context "3 hours worked" do
        should "not be a night worker" do
          add_response "3"
          assert_current_node :not_a_night_worker
        end
      end

      context "4 hours worked" do
        setup do
          add_response "4"
        end

        should "ask if rest period taken" do
          assert_current_node :taken_rest_period?
        end

        context "rest not taken" do
          should "say limit is exceeded" do
            add_response :no
            assert_current_node :limit_exceeded
          end
        end

        context "rest taken" do
          setup do
            add_response :yes
          end

          should "ask for the reference period" do
            assert_current_node :break_between_shifts?
          end

          context "no had a break" do
            should "say limit exceeded" do
              add_response :no
              assert_current_node :limit_exceeded
            end
          end

          context "had a break" do
            setup do
              add_response :yes
            end

            should "ask for reference period" do
              assert_current_node :reference_period?
            end

            context "54 weeks" do
              should "error" do
                add_response "54"
                assert_current_node :reference_period?
              end
            end

            context "2 weeks" do
              setup do
                add_response "2"
              end

              should "ask for weeks of leave" do
                assert_current_node :weeks_of_leave?
              end

              context "1 weeks taken off" do
                setup do
                  add_response "1"
                end

                should "ask for work cycle" do
                  assert_current_node :what_is_your_work_cycle?
                end

                context "7 day cycle" do
                  setup do
                    add_response "7"
                  end

                  should "ask for nights in cycle" do
                    assert_current_node :nights_per_cycle?
                  end

                  context "2 nights per cycle" do
                    setup do
                      add_response "2"
                    end

                    should "ask for hours per night" do
                      :hours_per_night?
                    end

                    context "3 hours per night" do
                      should "say not a night worker" do
                        add_response "3"
                        assert_current_node :not_a_night_worker
                      end
                    end

                    context "14 hours per night" do
                      should "say exceeded limits" do
                        add_response "14"
                        assert_current_node :limit_exceeded
                      end
                    end

                    context "4 hours per night" do
                      setup do
                        add_response "4"
                      end

                      should "ask for overtime hours during reference period" do
                        assert_current_node :overtime_hours?
                      end

                      context "calculation result is 8 hours" do
                        should "show legal result" do
                          add_response "1"
                          assert_current_node :within_legal_limit
                        end
                      end

                      context "calculation result is 9 hours" do
                        should "show illegal result" do
                          add_response "10"
                          assert_current_node :outside_legal_limit
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
    end
  end
end