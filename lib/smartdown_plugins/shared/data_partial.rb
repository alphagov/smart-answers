require 'erb'
require 'tilt'

module DataPartial
  def render(template_name, opts = {})
    directory = opts.fetch(:directory, data_partial_template_directory)
    filepath = File.join(directory, "_#{template_name}.erb")
    locals = opts.fetch(:locals, nil)
    Tilt.new(filepath).render(OpenStruct.new(locals))
  end

  def data_partial_template_directory
    File.join(Rails.root, 'lib', 'smart_answer_flows', 'data_partials')
  end
end
