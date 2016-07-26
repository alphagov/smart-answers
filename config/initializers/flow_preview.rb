# This file potentially overwritten on deploy

if Rails.env.production?
  FLOW_REGISTRY_OPTIONS = {}
else
  FLOW_REGISTRY_OPTIONS = { show_drafts: true }
end

# Uncomment the following to run smartanswers with the test flows instead of the real ones
#
#FLOW_REGISTRY_OPTIONS[:smart_answer_load_path] = Rails.root.join('test', 'fixtures', 'smart_answer_flows')
