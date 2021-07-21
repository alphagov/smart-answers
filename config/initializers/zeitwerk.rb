Rails.autoloaders.each do |autoloader|
  # Flows in the shared directory use the same namespace as other Flows.
  autoloader.collapse("app/flows/shared")

  # These directories contain template files and may not have Zeitwerk naming
  # conventions
  autoloader.ignore("app/flows/**/outcomes/*")
  autoloader.ignore("app/flows/**/questions/*")
end
