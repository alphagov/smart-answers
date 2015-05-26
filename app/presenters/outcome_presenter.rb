require 'erubis'

class OutcomePresenter < NodePresenter
  def initialize(i18n_prefix, node, state = nil, options = {})
    @options = options
    super(i18n_prefix, node, state)
  end

  def title
    if use_template? && title_erb_template_exists?
      view_context = @state.dup
      safe_level, trim_mode = nil, '-'
      title = ERB.new(title_erb_template_from_file, safe_level, trim_mode).result(view_context.instance_eval { binding })
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

  def calendar
    @node.evaluate_calendar(@state)
  end

  def has_calendar?
    calendar.present?
  end

  def body
    if use_template? && body_erb_template_exists?
      view_context = @state.dup
      view_context.extend(ActionView::Helpers::NumberHelper)
      safe_level, trim_mode = nil, '-'
      govspeak = ERB.new(body_erb_template_from_file, safe_level, trim_mode).result(view_context.instance_eval { binding })
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
    Rails.root.join("lib/smart_answer_flows/#{@node.flow_name}/#{name}_title.txt.erb")
  end

  def body_erb_template_from_file
    File.read(body_erb_template_path)
  end

  def body_erb_template_path
    @options[:body_erb_template_path] || default_body_erb_template_path
  end

  def default_body_erb_template_path
    Rails.root.join("lib/smart_answer_flows/#{@node.flow_name}/#{name}_body.govspeak.erb")
  end

  private

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
