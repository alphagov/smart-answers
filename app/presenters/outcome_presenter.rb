class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    super(i18n_prefix, node, state)
    @template_directory = options[:erb_template_directory] || @node.template_directory
    @view = ActionView::Base.new([@template_directory])
    @view.extend(SmartAnswer::OutcomeHelper)
    @view.extend(SmartAnswer::OverseasPassportsHelper)
    @view.extend(SmartAnswer::MarriageAbroadHelper)
  end

  def title
    title = content_for(:title, govspeak: false)
    title && title.chomp
  end

  def body(html: true)
    content_for(:body, html: html)
  end

  def next_steps(html: true)
    content_for(:next_steps, html: html)
  end

  def erb_template_path
    @template_directory.join(erb_template_name)
  end

  def erb_template_name
    "#{name}.govspeak.erb"
  end

  private

  def content_for(key, html: true, govspeak: true)
    if erb_template_exists_for?(key)
      content = rendered_view.content_for(key) || ''
      content = strip_leading_spaces(content.to_str)
      (html && govspeak) ? GovspeakPresenter.new(content).html : content
    end
  end

  def erb_template_exists_for?(key)
    File.exists?(erb_template_path) && has_content_for?(key)
  end

  def rendered_view
    @rendered_view ||= @view.tap do |view|
      view.render(template: erb_template_name, locals: @state.to_hash)
    end
  end

  def has_content_for?(key)
    File.read(erb_template_path) =~ /content_for #{key.inspect}/
  end

  def strip_leading_spaces(string)
    string.gsub(/^ +/, '')
  end
end
