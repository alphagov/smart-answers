module ApplicationHelper
  def title_for_head(answer_title:, title_prefix: nil)
    [title_prefix, answer_title, "GOV.UK"].compact.join(" - ")
  end
end
