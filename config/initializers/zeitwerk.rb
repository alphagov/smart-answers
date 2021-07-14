Rails.autoloaders.each do |autoloader|
  flow_inflector = Class.new(Zeitwerk::Inflector) do
    def camelize(basename, abspath)
      # Smart Answer Flow classes don't have a conventional Ruby file path
      # and instead use a kebab-case approach of the flow's slug
      if abspath.include?("smart_answer_flows") && basename.include?("-")
        super "#{basename.gsub('-', '_')}_flow", abspath
      else
        super
      end
    end
  end

  autoloader.inflector = flow_inflector.new

  # Smart Answer Flow classes are stored in a lib/smart_answer_flows directory
  # but aren't under a SmartAnswerFlows namespace. These files are intended
  # to move to an app/flows directory.
  autoloader.collapse("lib/smart_answer_flows")
  # Flows in the shared directory use the same namespace as other Flows.
  autoloader.collapse("lib/smart_answer_flows/shared")
end
