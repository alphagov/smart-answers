module SmartAnswer
  class LegalisationDocumentCheckerFlow < Flow
    def define
      name 'legalisation-document-checker'
      status :published
      satisfies_need "101010"

      i18n_prefix = "flow.legalisation-document-checker"

      #Q1
      checkbox_question :which_documents_do_you_want_legalised? do
        option "acro-police-certificate"
        option "affidavit"
        option "articles-of-association"
        option "bank-statement"
        option "baptism-certificate"
        option "birth-certificate"
        option "certificate-of-incorporation"
        option "certificate-of-freesale"
        option "certificate-of-memorandum"
        option "certificate-of-naturalisation"
        option "certificate-of-no-impediment"
        option "chamber-of-commerce-document"
        option "change-of-name-deed"
        option "civil-partnership-certificate"
        option "criminal-records-bureau-document"
        option "criminal-records-check"
        option "companies-house-document"
        option "county-court-document"
        option "court-document"
        option "court-of-bankruptcy-document"
        option "death-certificate"
        option "decree-nisi"
        option "decree-absolute"
        option "degree-certificate-uk"
        option "department-of-business-innovation-skills-document"
        option "department-of-health-document"
        option "diploma"
        option "disclosure-scotland-document"
        option "doctor-letter-medical"
        option "driving-licence"
        option "educational-certificate-uk"
        option "export-certificate"
        option "family-division-high-court-justice-document"
        option "fingerprints"
        option "fit-note-from-a-doctor"
        option "government-issued-document"
        option "grant-of-probate"
        option "high-court-justice-document"
        option "hmrc-document"
        option "home-office-document"
        option "last-will-testament"
        option "letter-from-employer"
        option "letter-of-enrolment"
        option "letter-of-invitation"
        option "letter-of-no-trace"
        option "medical-report"
        option "marriage-certificate"
        option "name-change-deed-or-document"
        option "passport-copy-only"
        option "pet-export-document"
        option "police-disclosure-document"
        option "power-of-attorney"
        option "probate"
        option "reference-from-an-employer"
        option "religious-document"
        option "sheriff-court-document"
        option "sick-note-from-doctor"
        option "statutory-declaration"
        option "test-results-medical"
        option "translation"
        option "utility-bill"

        calculate :choices do |response|
          raise InvalidResponse if response == 'none'
          response.split(',')
        end

        next_node :outcome_results
      end

      use_outcome_templates

      outcome :outcome_results do
        precalculate :data_query do
          SmartAnswer::Calculators::LegalisationDocumentsDataQuery.new
        end

        precalculate :groups_selected do
          choices.map do |choice|
            info = data_query.find_document_data choice
            info["group"]
          end
        end

        precalculate :no_content do
          # all apart from birth_death, certificate_impediment and medical_reports
          no_content = (groups_selected - ["birth_death", "certificate_impediment", "medical_reports", "vet_health"]).size > 0
        end
      end
    end
  end
end
