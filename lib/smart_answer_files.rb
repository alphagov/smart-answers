class SmartAnswerFiles
  def initialize(flow_name, *additional_files_paths)
    @flow_name = flow_name
    @additional_files_paths = additional_files_paths.map do |path|
      Pathname.new(path)
    end
  end

  def paths
    relative_paths.map(&:to_s).uniq
  end

  private

  def relative_paths
    all_paths.collect do |path|
      path.relative_path_from(Rails.root)
    end
  end

  def all_paths
    [flow_path, locale_path] + erb_template_paths + additional_files_absolute_paths
  end

  def erb_template_directory
    Rails.root.join('lib', 'smart_answer_flows', @flow_name)
  end

  def erb_template_paths
    Dir[erb_template_directory.join('*.erb')].collect do |path|
      Pathname.new(path)
    end
  end

  def additional_files_absolute_paths
    @additional_files_paths.map(&:realpath)
  end

  def flow_path
    Rails.root.join('lib', 'smart_answer_flows', "#{@flow_name}.rb")
  end

  def locale_path
    Rails.root.join('lib', 'smart_answer_flows', 'locales', 'en', "#{@flow_name}.yml")
  end
end
