Rails.autoloaders.each do |autoloader|
  # Flows in the shared directory use the same namespace as other Flows.
  autoloader.collapse("app/flows/shared")
end
