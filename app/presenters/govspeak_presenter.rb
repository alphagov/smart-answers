class GovspeakPresenter
  def initialize(markup)
    @markup = markup
  end

  def html
    Govspeak::Document.new(@markup).to_html.html_safe
  end
end
