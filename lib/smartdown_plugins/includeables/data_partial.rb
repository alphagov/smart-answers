module DataPartial
  def render(template_name, opts={})
    locals = opts.fetch(:locals, nil)
    ApplicationController.new.render_to_string(
      :file => File.join(Rails.root, 'lib', 'smart_answer_flows', 'data_partials', "_#{template_name}.erb"),
      :layout => false,
      :locals => locals
    )
  end
end
