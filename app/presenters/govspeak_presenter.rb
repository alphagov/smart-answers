require "gds_api/fact_cave"

class GovspeakPresenter
  EMBEDDED_FACT_REGEXP = /\[fact\:([a-z0-9-]+)\]/i # e.g. [fact:vat-rates]

  def initialize(markup)
    @markup = markup
  end

  def html
    html = Govspeak::Document.new(@markup).to_html.html_safe
    interpolate_fact_values(html)
  end

  private

  def interpolate_fact_values(string)
    return string unless string.match(EMBEDDED_FACT_REGEXP)

    string.gsub(EMBEDDED_FACT_REGEXP) do |match|
      if fact = $fact_cave.fact($1)
        fact.details.value
      else
        ''
      end
    end
  end
end
