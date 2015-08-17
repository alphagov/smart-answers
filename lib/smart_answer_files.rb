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

  def existing_paths
    @existing_paths ||= paths.select { |path| File.exist?(path) }
  end

  def empty?
    existing_paths.empty?
  end

  private

  def relative_paths
    @relative_paths ||= all_paths.collect do |path|
      path.relative_path_from(Rails.root)
    end
  end

  def all_paths
    [
      flow_path,
      locale_path,
      questions_and_responses_test_data_path,
      responses_and_expected_results_test_data_path
    ] + erb_template_paths + smartdown_file_paths + additional_files_absolute_paths
  end

  def erb_template_directory
    Rails.root.join('lib', 'smart_answer_flows', @flow_name)
  end

  def smartdown_flows_directory
    Rails.root.join('lib', 'smartdown_flows', @flow_name)
  end

  def erb_template_paths
    Dir[erb_template_directory.join('*.erb')].collect do |path|
      Pathname.new(path)
    end
  end

  def smartdown_file_paths
    ['outcomes/*.txt', 'questions/*.txt', 'snippets/*.txt', '*.txt'].flat_map do |pattern|
      Dir[smartdown_flows_directory.join(pattern)].collect do |path|
        Pathname.new(path)
      end
    end
  end

  def additional_files_absolute_paths
    @additional_files_paths.select(&:exist?).map(&:realpath)
  end

  def flow_path
    Rails.root.join('lib', 'smart_answer_flows', "#{@flow_name}.rb")
  end

  def locale_path
    Rails.root.join('lib', 'smart_answer_flows', 'locales', 'en', "#{@flow_name}.yml")
  end

  def questions_and_responses_test_data_path
    SmartAnswerTestHelper.new(@flow_name).question_and_responses_path
  end

  def responses_and_expected_results_test_data_path
    SmartAnswerTestHelper.new(@flow_name).responses_and_expected_results_path
  end
end
