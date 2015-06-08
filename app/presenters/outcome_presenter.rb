class OutcomePresenter < NodePresenter
  class ViewContext
    def initialize(state)
      @state = state
    end

    def method_missing(method, *args, &block)
      if method_can_be_delegated_to_state?(method)
        @state.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      method_can_be_delegated_to_state?(method)
    end

    def get_binding
      binding
    end

    private

    def method_can_be_delegated_to_state?(method)
      @state.respond_to?(method) && !method.to_s.end_with?('=')
    end
  end

  def initialize(i18n_prefix, node, state = nil, options = {})
    @options = options
    super(i18n_prefix, node, state)
  end

  def title
    if use_template? && title_erb_template_exists?
      view_context = ViewContext.new(@state)
      title = render_erb_template(title_erb_template_from_file, view_context)
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

  def body
    if use_template? && body_erb_template_exists?
      view_context = ViewContext.new(@state)
      view_context.extend(ActionView::Helpers::NumberHelper)
      govspeak = render_erb_template(body_erb_template_from_file, view_context)
      GovspeakPresenter.new(govspeak).html
    else
      super()
    end
  end

  def title_erb_template_from_file
    File.read(title_erb_template_path)
  end

  def title_erb_template_path
    @options[:title_erb_template_path] || default_title_erb_template_path
  end

  def default_title_erb_template_path
    template_directory.join("#{name}_title.txt.erb")
  end

  def body_erb_template_from_file
    File.read(body_erb_template_path)
  end

  def body_erb_template_path
    @options[:body_erb_template_path] || default_body_erb_template_path
  end

  def default_body_erb_template_path
    template_directory.join("#{name}_body.govspeak.erb")
  end

  private

  def template_directory
    @node.template_directory
  end

  def render_erb_template(template, view_context)
    safe_level, trim_mode = nil, '-'
    ERB.new(template, safe_level, trim_mode).result(view_context.get_binding)
  end

  def title_erb_template_exists?
    File.exists?(title_erb_template_path)
  end

  def body_erb_template_exists?
    File.exists?(body_erb_template_path)
  end

  def use_template?
    @node.use_template?
  end

  def render_data_partial(partial, variable_name)
    data = @state.send(variable_name.to_sym)

    partial_path = ::SmartAnswer::FlowRegistry.instance.load_path.join("data_partials", "_#{partial}")
    ApplicationController.new.render_to_string(file: partial_path.to_s, layout: false, locals: {variable_name.to_sym => data})
  end
end
