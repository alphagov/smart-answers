# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BecomeADrivingInstructorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'become-a-driving-instructor'
  end

  should "ask if you've had a licence for 4 of the last 6 years" do
    assert_current_node :have_you_had_licence_for_4_of_6_years?
  end

  should "not be possible if you've not have a licence for long enough" do
    add_response :no
    assert_current_node :havent_had_licence_for_long_enough
  end

  context "having had a licence for long enough" do
    setup do
      add_response :yes
    end

    should "ask if you've been disqualified from driving in last 4 years" do
      assert_current_node :have_you_been_disqualified_in_last_4_years?
    end

    should "not be allowed if you've been disqualified" do
      add_response :yes
      assert_current_node :cant_because_disqualified
    end

    context "without disqualifications" do
      setup do
        add_response :no
      end

      should "ask if you have a criminal record" do
        assert_current_node :do_you_have_a_criminal_record?
      end

      context "without a criminal record" do
        setup do
          add_response :no
        end

        should "ask if you have a disability" do
          assert_current_node :do_you_have_a_disability?
        end

        context "without a disability" do
          setup do
            add_response :no
          end

          should "ask if you're already registered in another EC country" do
            assert_current_node :are_you_driving_instructor_in_ec_country?
          end

          should "be able to apply if not an EC instructor" do
            add_response :no
            assert_current_node :can_start_process_of_applying
          end

          should "be able to apply to transfer if an EC instructor" do
            add_response :yes
            assert_current_node :can_apply_to_transfer_registration
          end
        end # without a disability

        context "with a disability" do
          setup do
            add_response :yes
          end

          should "ask if you're already registered in another EC country" do
            assert_current_node :are_you_driving_instructor_in_ec_country?
          end

          should "be able to apply if not an EC instructor" do
            add_response :no
            assert_current_node :can_start_process_of_applying_with_emergency_control
          end

          should "be able to apply to transfer if an EC instructor" do
            add_response :yes
            assert_current_node :can_apply_to_transfer_registration_with_emergency_control
          end
        end # with a disability
      end # without a criminal record

      context "with a criminal record" do
        setup do
          add_response :yes
        end

        should "ask if the offence is voilent or sex related" do
          assert_current_node :was_offence_violent_or_sex_related?
        end

        should "not be allowed if offence was violent or sex related" do
          add_response :yes
          assert_current_node :very_unlikely_because_of_criminal_record
        end

        context "non-voilent offence" do
          setup do
            add_response :no
          end

          should "ask if you have a disability" do
            assert_current_node :do_you_have_a_disability?
          end

          context "without a disability" do
            setup do
              add_response :no
            end

            should "ask if you're already registered in another EC country" do
              assert_current_node :are_you_driving_instructor_in_ec_country?
            end

            should "be able to apply if not an EC instructor" do
              add_response :no
              assert_current_node :can_start_process_of_applying_with_criminal_record
            end

            should "be able to apply to transfer if an EC instructor" do
              add_response :yes
              assert_current_node :can_apply_to_transfer_registration_with_criminal_record
            end
          end # without a disability

          context "with a disability" do
            setup do
              add_response :yes
            end

            should "ask if you're already registered in another EC country" do
              assert_current_node :are_you_driving_instructor_in_ec_country?
            end

            should "be able to apply if not an EC instructor" do
              add_response :no
              assert_current_node :can_start_process_of_applying_with_emergency_control_with_criminal_record
            end

            should "be able to apply to transfer if an EC instructor" do
              add_response :yes
              assert_current_node :can_apply_to_transfer_registration_with_emergency_control_with_criminal_record
            end
          end # with a disability
        end # non-voilent offence
      end # with a criminal record
    end # without disqualifications
  end # have licence for long enough
end
