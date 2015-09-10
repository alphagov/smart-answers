SmartAnswer::FlowRegistry.instance.flows.each do |flow|
  dummy_request = OpenStruct.new(params: {})
  flow_presenter = SmartAnswerPresenter.new(dummy_request, flow)
  start_node = flow_presenter.start_node

  blocks = []
  if start_node.has_title?
    blocks << "<% content_for :title do %>\n#{start_node.title.indent(2)}\n<% end %>\n"
  end
  if start_node.has_meta_description?
    blocks << "<% content_for :meta_description do %>\n#{start_node.meta_description.indent(2)}\n<% end %>\n"
  end
  if start_node.has_body?
    blocks << "<% content_for :body do %>\n#{start_node.body(html: false).chomp.indent(2)}\n<% end %>\n"
  end
  if start_node.has_post_body?
    blocks << "<% content_for :post_body do %>\n#{start_node.post_body(html: false).chomp.indent(2)}\n<% end %>\n"
  end

  directory = start_node.template_directory
  basename = directory.join(flow.name.underscore)
  filename = "#{basename}.govspeak.erb"
  File.open(filename, 'w') do |file|
    file.puts(blocks.join("\n"))
  end
end
