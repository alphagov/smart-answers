integration_test_path = Rails.root.join('test', 'integration', 'smart_answer_flows', 'pay_leave_for_parents_test.rb')

flow = SmartdownAdapter::Registry.instance.find('pay-leave-for-parents-old')

template_path = File.expand_path('../templates/integration_test.erb', __FILE__)
erb = File.read(template_path)
template = Erubis::Eruby.new(erb)
File.open(integration_test_path, 'w') do |file|
  file.write(template.result(binding))
end
