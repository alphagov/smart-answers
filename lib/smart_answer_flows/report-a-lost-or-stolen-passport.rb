class ReportALostOrStolenPassportFlow < SmartAnswer::Flow
  def define
    content_id "f02fc2c9-f5ff-4ea2-acc4-730bbda957bb"
    name "report-a-lost-or-stolen-passport"
    status :published

    radio :where_was_the_passport_lost_or_stolen? do
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
