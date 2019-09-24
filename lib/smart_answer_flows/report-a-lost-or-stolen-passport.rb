module SmartAnswer
  class ReportALostOrStolenPassportFlow < Flow
    def define
      start_page_content_id "f02fc2c9-f5ff-4ea2-acc4-730bbda957bb"
      flow_content_id "ba17a50d-611e-4df5-aa35-9339c4e20162"
      name "report-a-lost-or-stolen-passport"
      status :published
      satisfies_need "100221"

      multiple_choice :where_was_the_passport_lost_or_stolen? do
        option :in_the_uk
        option :abroad

        next_node do |response|
          case response
          when "in_the_uk"
            outcome :report_lost_or_stolen_passport
          when "abroad"
            outcome :contact_the_embassy
          end
        end
      end

      outcome :contact_the_embassy
      outcome :report_lost_or_stolen_passport
    end
  end
end
