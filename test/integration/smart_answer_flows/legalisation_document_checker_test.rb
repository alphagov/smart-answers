require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/legalisation-document-checker"

class LegalisationDocumentCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::LegalisationDocumentCheckerFlow
  end

  should "ask which documents you would like legalised" do
    assert_current_node :which_documents_do_you_want_legalised?
  end

  should "error if nothing selected" do
    add_response 'none'
    assert_current_node :which_documents_do_you_want_legalised?, error: true
  end

  context "doesnt include birth_data, certificate_impediment or medical_reports" do
    setup do
      add_response 'acro-police-certificate,affidavit'
    end

    should "show extra generic content" do
      assert_state_variable :no_content, true
    end
  end

  context "includes birth_data, certificate_impediment or medical_reports" do
    setup do
      add_response 'birth-certificate'
    end

    should "not show extra generic content" do
      assert_state_variable :no_content, false
    end
  end

  context "police disclosure documents" do
    setup do
      add_response 'acro-police-certificate,criminal-records-bureau-document,criminal-records-check,disclosure-scotland-document,fingerprints'
    end

    should "take you to the outcome for these police disclosure documents" do
      selected = [].tap { |ary|
        5.times do
          ary.push "police_disclosure"
        end
      }
      assert_state_variable :groups_selected, selected
    end
  end

  context "just one police disclosure documents" do
    setup do
      add_response 'acro-police-certificate'
    end

    should "take you to the outcome for the ACRO police certificate document" do
      assert_state_variable :groups_selected, ["police_disclosure"]
    end

    should "show the generic output" do
      assert_state_variable :no_content, true
    end
  end

  context "one police and one vet health documents" do
    setup do
      add_response 'acro-police-certificate,pet-export-document'
    end

    should "take you to the outcome for the ACRO police certificate document" do
      assert_state_variable :groups_selected, ["police_disclosure", "vet_health"]
    end

    should "show the generic content" do
      assert_state_variable :no_content, true
    end
  end

  context "vet health, birth_death" do
    setup do
      add_response 'pet-export-document,birth-certificate'
    end

    should "not show generic content" do
      assert_state_variable :no_content, false
    end
  end

  context "driving licence" do
    setup do
      add_response 'driving-licence'
    end

    should "take you to the outcome for the driving licence" do
      assert_state_variable :groups_selected, ["solicitors_notaries"]
    end
  end
end
