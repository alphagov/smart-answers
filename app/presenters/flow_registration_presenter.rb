class FlowRegistrationPresenter
  def initialize(flow)
    @flow = flow
    @i18n_prefix = "flow.#{@flow.name}"
  end

  def slug
    @flow.name
  end

  def need_id
    @flow.need_id
  end

  def title
    lookup_translation("title") || @flow.name.to_s.humanize
  end

  def paths
    ["/#{@flow.name}.json"]
  end

  def prefixes
    ["/#{@flow.name}"]
  end

  def description
    lookup_translation("meta.description")
  end

  NODE_PRESENTER_METHODS = [:title, :body, :hint]

  def indexable_content
    HTMLEntities.new.decode(
      text = @flow.nodes.inject([lookup_translation("body")]) do |acc, node|
        pres = NodePresenter.new(@i18n_prefix, node)
        acc.concat(NODE_PRESENTER_METHODS.map do |method|
          begin
            pres.send(method)
          rescue I18n::MissingInterpolationArgument
            # We can't do much about this, so we ignore these text nodes
            nil
          end
        end)
      end.compact.join(" ").gsub(/(?:<[^>]+>|\s)+/, " ")
    )
  end

  def state
    'live'
  end

private

  def lookup_translation(key)
    I18n.translate!("#{@i18n_prefix}.#{key}")
  rescue I18n::MissingTranslationData
    nil
  end
end
