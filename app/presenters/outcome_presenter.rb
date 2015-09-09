class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    @options = options
    super(i18n_prefix, node, state)
    @view = ActionView::Base.new([template_directory])
    @view.extend(SmartAnswer::OutcomeHelper)
    @view.extend(SmartAnswer::OverseasPassportsHelper)
    @view.extend(SmartAnswer::MarriageAbroadHelper)
  end

  def title
    if erb_template_exists_for?(:title)
      title = rendered_view.content_for(:title) || ''
      strip_leading_spaces(title.chomp)
    end
  end

  def body(html: true)
    if erb_template_exists_for?(:body)
      govspeak = rendered_view.content_for(:body) || ''
      govspeak = strip_leading_spaces(govspeak.to_str)
      html ? GovspeakPresenter.new(govspeak).html : govspeak
    end
  end

  def next_steps(html: true)
    if erb_template_exists_for?(:next_steps)
      govspeak = rendered_view.content_for(:next_steps) || ''
      govspeak = strip_leading_spaces(govspeak.to_str)
      html ? GovspeakPresenter.new(govspeak).html : govspeak
    end
  end

  def erb_template_path
    template_directory.join(erb_template_name)
  end

  def erb_template_name
    "#{name}.govspeak.erb"
  end

  private

  def template_directory
    @options[:erb_template_directory] || @node.template_directory
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
