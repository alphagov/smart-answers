module IndexHelper
  def title_and_url(flow_name, title)
    sanitize(title) + tag.br + link_to("/#{flow_name}", flow_landing_path(flow_name))
  end

  def live_link(flow_name, status)
    if status == :draft
      "https://draft-origin.publishing.service.gov.uk/#{flow_name}"
    else
      "https://www.gov.uk/#{flow_name}"
    end
  end

  def code_links(flow_name)
    link_to("Definition", "https://www.github.com/alphagov/smart-answers/blob/main/app/flows/#{flow_name}.rb") +
      tag.br +
      link_to("Content files", "https://www.github.com/alphagov/smart-answers/blob/main/app/flows/#{flow_name}")
  end
end
