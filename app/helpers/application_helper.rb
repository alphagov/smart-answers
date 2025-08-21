module ApplicationHelper
  def title_for_head(answer_title:, question_title:, outcome_title:)
    title = if question_title.present?
              "#{question_title} - #{answer_title}"
            elsif outcome_title.present?
              "#{outcome_title} - #{answer_title}"
            else
              answer_title
            end

    "#{title} - GOV.UK"
  end
end
