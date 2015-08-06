module SmartdownAdapter
  class PluginFactory
    class PluginModuleNotDefined < StandardError; end

    @@plugin_sets = {}

    def self.for(flow_slug)
      @@plugin_sets[flow_slug] ||= load_plugins_from_directory(flow_slug)
    end

    def self.add_plugin_module(flow_slug, plugin_type, plugin_module)
      @@plugin_sets[flow_slug] ||= {}
      @@plugin_sets[flow_slug][plugin_type] = build_plugin_set(plugin_module)
    end

    def self.reset_plugins_for(flow_slug)
      @@plugin_sets[flow_slug] = nil
    end

  private

    TYPES_OF_PLUGIN = [:render_time, :build_time]

    def self.load_plugins_from_directory(flow_slug)
      thing = {}.tap do |plugin_set|
        TYPES_OF_PLUGIN.each do |plugin_type|
          plugin_set[plugin_type] = load_plugins_from_file flow_slug, plugin_type
        end
      end
    end

    def self.load_plugins_from_file flow_slug, plugin_type
      plugin_file_path = plugin_path.join(flow_slug, "#{plugin_type}.rb")
      eval_paths = extendables_file_paths
      eval_paths << plugin_file_path

      evaluating_module = Module.new do
        eval_paths.each do |eval_path|
          module_eval File.read(eval_path), eval_path.to_s
        end
      end

      if plugin_module = get_descendant_constant_named(evaluating_module, module_name_from_slug(flow_slug))
        add_plugin_module(flow_slug, plugin_type, plugin_module)
      else
        raise PluginModuleNotDefined.new("Expected #{plugin_file_path} to define a module named #{module_name_from_slug(flow_slug)}")
      end

    rescue Errno::ENOENT
      # If no plugin file present, treat it as an empty plugin set
      {}
    end

    def self.build_plugin_set(plugin_module)
      {}.tap do |plugin_set|
        plugin_module.included_modules.each do |included_module|
          plugin_set.merge!(build_plugin_set(included_module))
        end
        plugin_module.singleton_methods.each {|method_name| plugin_set[method_name.to_s] = plugin_module.method(method_name) }
      end
    end

    def self.get_descendant_constant_named(parent_object, wanted_constant_name)
      wanted_constant_name = wanted_constant_name.to_sym

      if parent_object.constants.include? wanted_constant_name
        return parent_object.const_get(wanted_constant_name)
      else
        parent_object.constants.each do |constant_name|
          if wanted_constant = get_descendant_constant_named(parent_object.const_get(constant_name), wanted_constant_name)
            return wanted_constant
          end
        end
      end
      nil
    end

    def self.module_name_from_slug(flow_slug)
      flow_slug.gsub('-', '_').camelize
    end

    def self.extendables_file_paths
      Dir[extendable_path + '*.rb']
    end

    def self.extendable_path
      @@extendable_path ||= plugin_path.join('shared')
    end

    def self.plugin_path
      @@plugin_path ||= Rails.root.join('lib', 'smartdown_plugins')
    end
  end
end
