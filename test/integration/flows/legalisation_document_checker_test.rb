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

  context "police disclosure documents" do
    setup do
      add_response 'acro-police-certificate,criminal-records-bureau-document,criminal-records-check,disclosure-scotland-document,fingerprints'
    end

    should "take you to the outcome for these police disclosure documents" do
      assert_phrase_list :document_details, ["##ACRO Police Certificate\nYour ACRO Police Certificate can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", "##Criminal Records Bureau (CRB) document
Your CRB document can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", "##Criminal records check
Your criminal records check can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", "##Disclosure Scotland document
Your Disclosure Scotland document can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", "##Fingerprints
Your fingerprints can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
"]
    end
  end

  context "just one police disclosure documents" do
    setup do
      add_response 'acro-police-certificate'
    end

    should "take you to the outcome for the ACRO police certificate document" do
      assert_phrase_list :document_details, ["##ACRO Police Certificate\nYour ACRO Police Certificate can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", ]
    end
  end

  context "one police and one vet health documents" do
    setup do
      add_response 'acro-police-certificate,pet-export-document'
    end

    should "take you to the outcome for the ACRO police certificate document" do
      assert_phrase_list :document_details, ["##ACRO Police Certificate\nYour ACRO Police Certificate can be only be legalised if it has been:

- signed by an official from the issuing authority
- [certified](/certifying-a-document \"Certified copy of a document\")

^A photocopy of your document won’t be accepted.^
", "##Veterinary Health Certificate
Your Veterinary Health Certificate can only be legalised if it has been signed and stamped by a veterinary surgeon registered with the Department of Food and Rural Affairs.
"]
    end
  end

end
