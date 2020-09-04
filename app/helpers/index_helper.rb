module IndexHelper
  def title_and_url(flow_name, title)
    tag.p(title) + link_to("/#{flow_name}", smart_answer_path(flow_name))
  end

  def live_link(flow_name, status)
    if status == :draft
      "https://draft-origin.publishing.service.gov.uk/#{flow_name}"
    else
      "https://www.gov.uk/#{flow_name}"
    end
  end

  def code_links(flow_name)
    tag.p(link_to("Definition", "https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/#{flow_name}.rb")) +
      tag.p(link_to("Templates", "https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/#{flow_name}"))
  end
end
