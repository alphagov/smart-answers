class TextPresenter
  def initialize(flow)
    @flow = flow
    @i18n_prefix = "flow.#{@flow.name}"
  end

  NODE_PRESENTER_METHODS = [:title, :subtitle, :body, :hint]

  def text
    @flow.nodes.inject([translate("body")]) { |acc, node|
      pres = NodePresenter.new(@i18n_prefix, node)
      acc.concat(NODE_PRESENTER_METHODS.map { |method|
        lookup_ignoring_interpolation_errors(pres, method)
      })
    }.compact.join(" ")
  end

  def title
    translate("title")
  end

  def section_slug
    @flow.section_slug
  end

  def description
    translate("meta.description")
  end

private
  def lookup_ignoring_interpolation_errors(presenter, method)
    presenter.__send__(method)
  rescue I18n::MissingInterpolationArgument
    nil
  end

  def translate(subkey)
    key = [@i18n_prefix, subkey].join(".")
    I18n.translate!(key)
  rescue I18n::MissingTranslationData
    nil
  end
end
