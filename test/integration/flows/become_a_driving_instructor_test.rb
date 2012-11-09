# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class BecomeADrivingInstructorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'become-a-driving-instructor'
  end

  should "ask if you're 21 or over" do
    assert_current_node :are_you_21_or_over?
  end

  should "not be possible if under 21" do # response 1
    add_response :no
    assert_current_node :not_old_enough
    assert_phrase_list :content_sections, [:ADI_required_legal_warning, :acronym_definitions]
  end

  context "when 21 or over" do
    setup do
      add_response :yes
    end

    should "ask if you've had a licence for 3 years or more" do
      assert_current_node :have_you_had_licence_for_3_years?
    end

    should "not be possible if you haven't had licence for 3 years" do # response 2
      add_response :no
      assert_current_node :havent_had_licence_for_long_enough
      assert_phrase_list :content_sections, [:ADI_required_legal_warning, :acronym_definitions]
    end

    context "having had a licence for long enough" do
      setup do
        add_response :yes
      end

      should "ask if you're an EC ADI" do
        assert_current_node :are_you_driving_instructor_in_ec_country?
      end

      should "be able to transfer registration if EC ADI" do # response 3
        add_response :yes
        assert_current_node :can_apply_to_transfer_registration
        assert_phrase_list :content_sections, [:DSA_guide_to_ADI_register, :acronym_definitions]
      end

      context "not EC ADI" do
        setup do
          add_response :no
        end

        should "ask if you've been disqualified etc." do
          assert_current_node :have_you_been_disqualified_or_6_points?
        end

        should "be possible with caveats if have disqualifications etc." do # response 4
          add_response :yes
          assert_current_node :can_start_process_of_applying
          assert_phrase_list :content_sections, [:apply_to_dsa_with_endorsments, :apply_with_caveats_what_next, :DSA_guide_to_ADI_register, :acronym_definitions]
        end

        context "with no disqualifications etc." do
          setup do
            add_response :no
          end

          should "ask what type of licence you have" do
            assert_current_node :what_licence_type?
          end

          context "with a manual licence" do
            setup do
              add_response :manual
            end

            should "ask if you have any non-motoring convictions" do
              assert_current_node :non_motoring_offences?
            end

            should "be possible to apply with no convictions" do # response 6
              add_response :no
              assert_current_node :can_start_process_of_applying
              assert_phrase_list :content_sections, [:apply_steps, :criminal_record_check, :apply_to_dsa, :DSA_guide_to_ADI_register, :acronym_definitions]
            end

            should "be possible to apply with caveats with convictions" do # response 5
              add_response :yes
              assert_current_node :can_start_process_of_applying
              assert_phrase_list :content_sections, [:apply_to_dsa_with_criminal_record, :apply_with_caveats_what_next, :DSA_guide_to_ADI_register, :acronym_definitions]
            end
          end # manual licence

          context "with an automatic licence" do
            setup do
              add_response :automatic
            end

            should "ask if limited to automitic because of a disability" do
              assert_current_node :because_of_disability?
            end

            should "not be possible with limited licence" do # response 7
              add_response :no
              assert_current_node :cant_because_limited_licence
              assert_phrase_list :content_sections, [:ADI_required_legal_warning, :acronym_definitions]
            end

            context "limited die to disability" do
              setup do
                add_response :yes
              end

              should "ask if you have any non-motoring convictions" do
                assert_current_node :non_motoring_offences?
              end

              should "be possible to apply with no convictions" do # response 9
                add_response :no
                assert_current_node :can_start_process_of_applying
                assert_phrase_list :content_sections, [:apply_steps_with_emergency_control, :emergency_control, :criminal_record_check, :apply_to_dsa, :DSA_guide_to_ADI_register, :acronym_definitions]
              end

              should "be possible to apply with caveats with convictions" do # response 8
                add_response :yes
                assert_current_node :can_start_process_of_applying
                assert_phrase_list :content_sections, [:apply_to_dsa_with_criminal_record, :apply_with_caveats_and_emergency_control_what_next, :DSA_guide_to_ADI_register, :acronym_definitions]
              end
            end # limited fue to disability
          end # automatic licence
        end # without disqualifications
      end # not EC ADI
    end # have licence for long enough
  end # over 21
end
