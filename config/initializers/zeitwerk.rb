Rails.autoloaders.each do |autoloader|
  # Smart Answer Flow classes are stored in a lib/smart_answer_flows directory
  # but aren't under a SmartAnswerFlows namespace. These files are intended
  # to move to an app/flows directory.
  autoloader.collapse("lib/smart_answer_flows")
  # Flows in the shared directory use the same namespace as other Flows.
  autoloader.collapse("lib/smart_answer_flows/shared")
end
