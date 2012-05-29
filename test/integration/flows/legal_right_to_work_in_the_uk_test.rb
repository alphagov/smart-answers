# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class LegalRightToWorkInTheUKTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'legal-right-to-work-in-the-uk'
    @responses = []
  end

  should "ask if have UK passport" do
    assert_equal :have_uk_passport?, node_for_responses(@responses)
  end

  context "with a UK passport" do
    setup do
      @responses << 'yes'
    end

    should "ask if british citizen" do
      assert_equal :is_british_citizen?, node_for_responses(@responses)
    end

    should "be eligible1 if british citizen" do
      @responses << 'yes'
      assert_equal :is_eligible1, node_for_responses(@responses)
    end

    context "if not british citizen" do
      setup do
        @responses << 'no'
      end

      should "ask if has right of abode" do
        assert_equal :has_right_of_abode?, node_for_responses(@responses)
      end

      should "be eligible1 if has right of abode" do
        @responses << 'yes'
        assert_equal :is_eligible1, node_for_responses(@responses)
      end

      should "need up to date docs without right of abode" do
        @responses << 'no'
        assert_equal :needs_up_to_date_docs, node_for_responses(@responses)
      end
    end
  end # With UK passport

  context "without a UK passport" do
    setup do
      @responses << 'no'
    end

    should "ask where from" do
      assert_equal :where_from?, node_for_responses(@responses)
    end

    should "be eligible1 for CI, IoM or RoI" do
      @responses << 'from_ci_iom_ri'
      assert_equal :is_eligible1, node_for_responses(@responses)
    end

    should "be eligible2 for british citizen" do
      @responses << 'british'
      assert_equal :is_eligible2, node_for_responses(@responses)
    end

    context "from EU, EEA or Switzerland" do
      setup do
        @responses << 'from_eu_eea_switzerland'
      end

      should "ask if has eu passport or ID" do
        assert_equal :has_eu_passport_or_id?, node_for_responses(@responses)
      end

      should "be eligible3 with EU ID or passport" do
        @responses << 'yes'
        assert_equal :is_eligible3, node_for_responses(@responses)
      end

      context "without a EU ID or passport" do
        setup do
          @responses << 'no'
        end

        should "ask if has named person" do
          assert_equal :has_named_person?, node_for_responses(@responses)
        end

        should "be eligible3 with named person" do
          @responses << 'yes'
          assert_equal :is_eligible3, node_for_responses(@responses)
        end

        should "be maybe1 without named person" do
          @responses << 'no'
          assert_equal :maybe1, node_for_responses(@responses)
        end
      end
    end # EU, EEA, Switzerland

    context "From somewhere else" do
      setup do
        @responses << 'from_somewhere_else'
      end

      should "ask if has other permit" do
        assert_equal :has_other_permit?, node_for_responses(@responses)
      end

      should "be eligible1 with other permit" do
        @responses << 'yes'
        assert_equal :is_eligible1, node_for_responses(@responses)
      end

      context "without other permit" do
        setup do
          @responses << 'no'
        end

        should "ask if has nic and other documents" do
          assert_equal :has_nic_and_other_doc?, node_for_responses(@responses)
        end

        should "be eligible2 with nic and other documents" do
          @responses << 'yes'
          assert_equal :is_eligible2, node_for_responses(@responses)
        end

        context "without nic and other documents" do
          setup do
            @responses << 'no'
          end
          
          should "ask if has visa or other documents" do
            assert_equal :has_visa_or_other_doc?, node_for_responses(@responses)
          end

          should "be maybe1 with visa or other documents" do
            @responses << 'yes'
            assert_equal :maybe1, node_for_responses(@responses)
          end

          should "be maybe2 without visa or other documents" do
            @responses << 'no'
            assert_equal :maybe2, node_for_responses(@responses)
          end
        end
      end # without other permit
    end # somewhere else
  end # without a UK passport
end
