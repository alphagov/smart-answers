# If an env var isn't to specify showing drafts we'll decide it based on Rails
# environment
show_drafts = ENV["SHOW_DRAFT_FLOWS"] ? true : !Rails.env.production?

FLOW_REGISTRY_OPTIONS = { show_drafts: show_drafts } # rubocop:disable Style/MutableConstant

# Uncomment the following to run smartanswers with the test flows instead of the real ones
#
#FLOW_REGISTRY_OPTIONS[:smart_answer_load_path] = Rails.root.join('test', 'fixtures', 'smart_answer_flows')
