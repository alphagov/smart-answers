require_relative "../../test_helper"
require_relative "flow_test_helper"

class ReportALostOrStolenPassportTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "report-a-lost-or-stolen-passport"
  end

  should "ask whether your passport has been lost or stolen" do
    assert_current_node :has_your_passport_been_lost_or_stolen?
  end

  context "Lost passport" do
    setup do
      add_response :lost
    end

    should "ask whether the passport is for a child or an adult" do
      assert_current_node :adult_or_child_passport?
    end

    context "for an Adult" do
      setup do
        add_response :adult
      end

      should "ask where your passport was lost" do
        assert_current_node :where_was_the_passport_lost?
      end

      context "in the UK" do
        setup do
          add_response :in_the_uk
        end

        should "tell you to fill out the LS01 form" do
          assert_current_node :complete_LS01_form
          assert_phrase_list :child_advice, []
          assert_state_variable :lost_or_stolen, 'lost'
        end
      end

      context "abroad" do
        setup do
          add_response :abroad
        end

        should "ask which country you lost your passport in" do
          assert_current_node :which_country?
        end

        context "in Azerbaijan" do
          setup do
            add_response "azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_current_node :contact_the_embassy
            assert_phrase_list :child_advice, []
            assert_state_variable :lost_or_stolen, 'lost'
          end
        end
      end
    end

    context "for a Child" do
      setup do
        add_response :child
      end

      should "ask where your passport was lost" do
        assert_current_node :where_was_the_passport_lost?
      end

      context "in UK" do
        setup do
          add_response :in_the_uk
        end

        should "tell you to fill out the LS01 form" do
          assert_current_node :complete_LS01_form
          assert_phrase_list :child_advice, [:child_forms]
          assert_state_variable :lost_or_stolen, 'lost'
        end
      end

      context "Abroad" do
        setup do
          add_response :abroad
        end

        should "ask which country you lost your passport in" do
          assert_current_node :which_country?
        end

        context "in Azerbaijan" do
          setup do
            add_response "azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_current_node :contact_the_embassy
            assert_phrase_list :child_advice, [:child_forms]
            assert_state_variable :lost_or_stolen, 'lost'
          end
        end
      end
    end
  end

  context "Passport stolen" do
    setup do
      add_response :stolen
    end

    should "ask whether the passport is for a child or adult" do
      assert_current_node :adult_or_child_passport?
    end

    context "for an Adult" do
      setup do
        add_response :adult
      end

      should "ask where your passport was stolen" do
        assert_current_node :where_was_the_passport_stolen?
      end

      context "in the UK" do
        setup do
          add_response :in_the_uk
        end

        should "tell you to report it to the police" do
          assert_current_node :contact_the_police
          assert_phrase_list :child_advice, []
          assert_state_variable :lost_or_stolen, 'stolen'
        end
      end

      context "abroad" do
        setup do
          add_response :abroad
        end

        should "ask in which country your passport was stolen" do
          assert_current_node :which_country?
        end

        context "in Azerbaijan" do
          setup do
            add_response "azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_current_node :contact_the_embassy
            assert_phrase_list :child_advice, []
            assert_state_variable :lost_or_stolen, 'stolen'
          end
        end
      end
    end

    context "for a Child" do
      setup do
        add_response :child
      end

      should "ask where your passport was stolen" do
        assert_current_node :where_was_the_passport_stolen?
      end

      context "in the UK" do
        setup do
          add_response :in_the_uk
        end

        should "tell you to report it to the police" do
          assert_current_node :contact_the_police
          assert_phrase_list :child_advice, [:child_forms]
            assert_state_variable :lost_or_stolen, 'stolen'
        end
      end

      context "abroad" do
        setup do
          add_response :abroad
        end

        should "ask in which country your passport was stolen" do
          assert_current_node :which_country?
        end

        context "in Azerbaijan" do
          setup do
            add_response "azerbaijan"
          end

          should "tell you to report it to the embassy" do
            assert_current_node :contact_the_embassy
            assert_phrase_list :child_advice, [:child_forms]
            assert_state_variable :lost_or_stolen, 'stolen'
          end
        end
      end
    end
  end
end