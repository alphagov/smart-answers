flows = SmartAnswer::FlowRegistry.instance.flows
data = flows.sort_by(&:name).inject({}) do |hash, flow|
  hash[flow.name] = flow.questions.sort_by(&:name).inject({}) do |q_vs_pnn, question|
    q_vs_pnn[question.name] = question.permitted_next_nodes.sort
    q_vs_pnn
  end
  hash
end

path = Rails.root.join('test', 'data', 'permitted-next-nodes.yml')
File.write(path, data.to_yaml)
