class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    @options = options
    super(i18n_prefix, node, state)
    @view = ActionView::Base.new([template_directory])
    @view.extend(SmartAnswer::OutcomeHelper)
    @rendered_erb_template = false
  end

  def title
    if use_template? && title_erb_template_exists?
      render_erb_template
      title = @view.content_for(:title) || ''
      title.chomp
    else
      translate!('title')
    end
  end

  def translate!(subkey)
    output = super(subkey)
    if output
      output.gsub!(/\+\[data_partial:(\w+):(\w+)\]/) do |match|
        render_data_partial($1, $2)
      end
    end

    output
  end

  def body(html: true)
    if use_template? && body_erb_template_exists?
      render_erb_template
      govspeak = @view.content_for(:body) || ''
      html ? GovspeakPresenter.new(govspeak.to_str).html : govspeak.to_str
    else
      super()
    end
  end

  def next_steps(html: true)
    if use_template? && next_steps_erb_template_exists?
      render_erb_template
      govspeak = @view.content_for(:next_steps) || ''
      html ? GovspeakPresenter.new(govspeak.to_str).html : govspeak.to_str
    else
      super()
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

  def title_erb_template_exists?
    erb_template_exists? && has_content_for_title?
  end

  def body_erb_template_exists?
    erb_template_exists? && has_content_for_body?
  end

  def next_steps_erb_template_exists?
    erb_template_exists? && has_content_for_next_steps?
  end

  def erb_template_exists?
    File.exists?(erb_template_path)
  end

  def use_template?
    @node.use_template?
  end

  def render_data_partial(partial, variable_name)
    data = @state.send(variable_name.to_sym)

    partial_path = ::SmartAnswer::FlowRegistry.instance.load_path.join("data_partials", "_#{partial}")
    ApplicationController.new.render_to_string(file: partial_path.to_s, layout: false, locals: {variable_name.to_sym => data})
  end

  def render_erb_template
    unless @rendered_erb_template
      @view.render(template: erb_template_name, locals: @state.to_hash)
      @rendered_erb_template = true
    end
  end

  def has_content_for_body?
    File.read(erb_template_path) =~ /content_for :body/
  end

  def has_content_for_title?
    File.read(erb_template_path) =~ /content_for :title/
  end

  def has_content_for_next_steps?
    File.read(erb_template_path) =~ /content_for :next_steps/
  end
end
