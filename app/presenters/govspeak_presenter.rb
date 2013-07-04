require "gds_api/fact_cave"

class GovspeakPresenter
  EMBEDDED_FACT_REGEXP = /\[fact\:([a-z0-9-]+)\]/i # e.g. [fact:vat-rates]

  def initialize(markup)
    @markup = markup
  end

  def html
    markdown_with_facts = interpolate_fact_values(@markup)
    Govspeak::Document.new(markdown_with_facts).to_html.html_safe
  end

  private

  def interpolate_fact_values(string)
    return string if !string.match(EMBEDDED_FACT_REGEXP)

    string.gsub(EMBEDDED_FACT_REGEXP) do |match|
      if fact = $fact_cave.fact($1)
        fact.details.value
      else
        ''
      end
    end
  end
end
