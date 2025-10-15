module ApplicationHelper
  def title_for_head(answer_title:, title_prefix: nil)
    [title_prefix.presence, answer_title, "GOV.UK"].compact.join(" - ")
  end
end
