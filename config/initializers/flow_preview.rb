# This file potentially overwritten on deploy

if Rails.env.production?
  FLOW_REGISTRY_OPTIONS = {}
else
  FLOW_REGISTRY_OPTIONS = {show_drafts: true}
end

# Uncomment the following to run smartanswers with the test flows instead of the real ones
#
#FLOW_REGISTRY_OPTIONS[:load_path] = Rails.root.join('test', 'fixtures', 'flows')
#I18n.load_path += Dir[Rails.root.join(*%w{test fixtures flows locales * *.{rb,yml}})]
