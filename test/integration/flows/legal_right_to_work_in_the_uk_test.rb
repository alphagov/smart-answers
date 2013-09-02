# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class LegalRightToWorkInTheUKTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'legal-right-to-work-in-the-uk'
  end

  should "ask if have UK passport" do
    assert_current_node :have_uk_passport?
  end

  context "with a UK passport" do
    setup do
      add_response 'yes'
    end

    should "ask if british citizen" do
      assert_current_node :is_british_citizen?
    end

    should "be eligible1 if british citizen" do
      add_response 'yes'
      assert_current_node :is_eligible1
    end

    context "if not british citizen" do
      setup do
        add_response 'no'
      end

      should "ask if has right of abode" do
        assert_current_node :has_right_of_abode?
      end

      should "be eligible1 if has right of abode" do
        add_response 'yes'
        assert_current_node :is_eligible1
      end

      should "need up to date docs without right of abode" do
        add_response 'no'
        assert_current_node :needs_up_to_date_docs
      end
    end
  end # With UK passport

  context "without a UK passport" do
    setup do
      add_response 'no'
    end

    should "ask where from" do
      assert_current_node :where_from?
    end

    should "be eligible1 for CI, IoM or RoI" do
      add_response 'from_ci_iom_ri'
      assert_current_node :is_eligible1
    end

    should "be eligible2 for british citizen" do
      add_response 'british'
      assert_current_node :is_eligible2
    end

    context "from EU, EEA or Switzerland" do
      setup do
        add_response 'from_eu_eea_switzerland'
      end

      should "ask if has eu passport or ID" do
        assert_current_node :has_eu_passport_or_id?
      end

      should "be eligible3 with EU ID or passport" do
        add_response 'yes'
        assert_current_node :is_eligible3
      end

      context "without a EU ID or passport" do
        setup do
          add_response 'no'
        end

        should "ask if has named person" do
          assert_current_node :has_named_person?
        end

        should "be eligible3 with named person" do
          add_response 'yes'
          assert_current_node :is_eligible3
        end

        should "be maybe1 without named person" do
          add_response 'no'
          assert_current_node :maybe1
        end
      end
    end # EU, EEA, Switzerland

    context "From somewhere else" do
      setup do
        add_response 'from_somewhere_else'
      end

      should "ask if has other permit" do
        assert_current_node :has_other_permit?
      end

      should "be eligible1 with other permit" do
        add_response 'yes'
        assert_current_node :is_eligible1
      end

      context "without other permit" do
        setup do
          add_response 'no'
        end

        should "ask if has nic and other documents" do
          assert_current_node :has_nic_and_other_doc?
        end

        should "be eligible2 with nic and other documents" do
          add_response 'yes'
          assert_current_node :is_eligible2
        end

        context "without nic and other documents" do
          setup do
            add_response 'no'
          end

          should "ask if has visa or other documents" do
            assert_current_node :has_visa_or_other_doc?
          end

          should "be maybe1 with visa or other documents" do
            add_response 'yes'
            assert_current_node :maybe1
          end

          should "be maybe2 without visa or other documents" do
            add_response 'no'
            assert_current_node :maybe2
          end
        end
      end # without other permit
    end # somewhere else
  end # without a UK passport
end
