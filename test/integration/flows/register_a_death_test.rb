# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class RegisterADeathTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'register-a-death'
  end

  should "ask where the death happened" do
    assert_current_node :where_did_the_death_happen?
  end

  context "death happened in England or Wales" do
    setup do
      add_response :england_wales
    end

    should "ask if the person died at home/in hospital or somewhere else" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end

    context "died at home/in hospital" do
      setup do
        add_response :at_home_hospital
      end

      should "ask whether the death was expected" do
        assert_current_node :was_death_expected?
      end

      should "be outcome1 if death was expected" do
        add_response :yes
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_home_hospital,
          :what_you_need_to_do_expected, :need_to_tell_registrar,
          :documents_youll_get_ew_expected
        ]
      end

      should "be outcome3 if death not expected" do
        add_response :no
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_home_hospital,
          :what_you_need_to_do_unexpected, :need_to_tell_registrar,
          :documents_youll_get_ew_unexpected
        ]
      end
    end # at home/hospital

    context "died elsewhere" do
      setup do
        add_response :elsewhere
      end

      should "ask whether the death was expected" do
        assert_current_node :was_death_expected?
      end

      should "be outcome2 if death was expected" do
        add_response :yes
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_elsewhere,
          :what_you_need_to_do_expected, :need_to_tell_registrar,
          :documents_youll_get_ew_expected
        ]
      end

      should "be outcome4 if death not expected" do
        add_response :no
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_ew,
          :who_can_register, :who_can_register_elsewhere,
          :what_you_need_to_do_unexpected, :need_to_tell_registrar,
          :documents_youll_get_ew_unexpected
        ]
      end
    end # elsewhere
  end # England or Wales

  context "death happened in Scotland, Northern Ireland or abroad" do
    setup do
      add_response :scotland_northern_ireland_abroad
    end

    should "ask if the person died at home/in hospital or somewhere else" do
      assert_current_node :did_the_person_die_at_home_hospital?
    end

    context "died at home/in hospital" do
      setup do
        add_response :at_home_hospital
      end

      should "ask whether the death was expected" do
        assert_current_node :was_death_expected?
      end

      should "be outcome5 if death was expected" do
        add_response :yes
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_other,
          :documents_youll_get_other_expected
        ]
      end

      should "be outcome7 if death not expected" do
        add_response :no
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_other, :intro_other_unexpected,
          :documents_youll_get_other_unexpected
        ]
      end
    end # at home/hospital

    context "died elsewhere" do
      setup do
        add_response :elsewhere
      end

      should "ask whether the death was expected" do
        assert_current_node :was_death_expected?
      end

      should "be outcome6 if death was expected" do
        add_response :yes
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_other,
          :documents_youll_get_other_expected
        ]
      end

      should "be outcome8 if death not expected" do
        add_response :no
        assert_current_node :done
        assert_phrase_list :content_sections, [:intro_other, :intro_other_unexpected,
          :documents_youll_get_other_unexpected
        ]
      end
    end # elsewhere
  end # Scotland, NI or abroad
end
