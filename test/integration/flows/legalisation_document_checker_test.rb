# encoding: UTF-8
require_relative "../../test_helper"
require_relative "flow_test_helper"

class DocumentLegalisationCheckerTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "legalisation-document-checker"
  end

  should "ask what documents you would like legalised" do
    assert_current_node :what_documents_do_you_want_legalised?
  end

  context "doesnt include birth_data, certificate_impediment or medical_reports" do
    setup do
      add_response 'acro-police-certificate,affidavit'
    end

    should "show extra generic content" do
      assert_phrase_list :generic_conditional_content, [:generic_certifying_content]
    end
  end

  context "includes birth_data, certificate_impediment or medical_reports" do
    setup do
      add_response 'birth-certificate'
    end

    should "not show extra generic content" do
      assert_phrase_list :generic_conditional_content, []
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
  end

  context "one police and one vet health documents" do
    setup do
      add_response 'acro-police-certificate,pet-export-document'
    end

    should "take you to the outcome for the ACRO police certificate document" do
      assert_state_variable :groups_selected, ["police_disclosure", "vet_health"]
    end
  end

end
