class SmartAnswerTestHelper
  def self.data_path
    Rails.root.join('test', 'data')
  end

  def self.artefacts_path
    Rails.root.join('test', 'artefacts')
  end

  def self.responses_and_expected_results
    Dir[data_path.join('*-responses-and-expected-results.yml')]
  end

  def initialize(flow_name)
    @flow_name = flow_name
  end

  def files_checksum_path
    data_path.join(files_checksum_filename)
  end

  def write_files_checksum(hasher)
    File.open(files_checksum_path, 'w') do |file|
      hasher.write_checksum_data(file)
    end
  end

  def read_files_checksums
    files_checksums_yaml = File.read(files_checksum_path)
    YAML.load(files_checksums_yaml)
  end

  def files_checksum_data_exists?
    File.exists?(files_checksum_path)
  end

  def run_regression_tests?
    explicitly_run_all_regression_tests? ||
      explicitly_run_this_regression_test? ||
      files_checksum_data_needs_updating?
  end

  def files_checksum_data_needs_updating?
    !files_checksum_data_exists? ||
      source_files_have_changed? ||
      source_files_have_been_added?
  end

  def question_and_responses_path
    data_path.join(question_and_responses_filename)
  end

  def write_questions_and_responses(questions_and_responses)
    FileUtils.mkdir_p(data_path)
    File.open(question_and_responses_path, 'w') do |file|
      file.puts(questions_and_responses.to_yaml)
    end
  end

  def responses_and_expected_results_path
    data_path.join(responses_and_expected_results_filename)
  end

  def write_responses_and_expected_results(data)
    File.open(responses_and_expected_results_path, 'w') do |file|
      file.puts(data.to_yaml)
    end
  end

  def read_responses_and_expected_results
    responses_and_expected_results_yaml = File.read(responses_and_expected_results_path)
    YAML.load(responses_and_expected_results_yaml)
  end

  def path_to_outputs_for_flow
    artefacts_path.join(@flow_name)
  end

  def save_output(responses, response)
    filename = responses.pop + '.txt'
    path_to_output_directory = path_to_outputs_for_flow.join(*responses)
    FileUtils.mkdir_p(path_to_output_directory)
    path_to_output_file = path_to_output_directory.join(filename)
    File.open(path_to_output_file, 'w') do |file|
      file.puts(response.body)
    end
    path_to_output_file
  end

  def delete_saved_output_files
    path = artefacts_path.join(@flow_name)
    FileUtils.rm_rf(path)
  end

  private

  def files_checksum_filename
    "#{@flow_name}-files.yml"
  end

  def question_and_responses_filename
    "#{@flow_name}-questions-and-responses.yml"
  end

  def responses_and_expected_results_filename
    "#{@flow_name}-responses-and-expected-results.yml"
  end

  def data_path
    self.class.data_path
  end

  def artefacts_path
    self.class.artefacts_path
  end

  def source_files_have_changed?
    checksum_data = read_files_checksums
    changed_files = checksum_data.select do |path, expected_checksum|
      content = File.read(path)
      actual_checksum = Digest::MD5.hexdigest(content)
      expected_checksum != actual_checksum
    end
    changed_files.any?
  end

  def explicitly_run_this_regression_test?
    ENV['RUN_REGRESSION_TESTS'] == @flow_name
  end

  def explicitly_run_all_regression_tests?
    ENV['RUN_REGRESSION_TESTS'] == 'true'
  end

  def source_files_have_been_added?
    checksum_data = read_files_checksums
    known_smart_answer_files = checksum_data.keys
    detected_smart_answer_files = SmartAnswerFiles.new(@flow_name)
    unknown_files = detected_smart_answer_files.paths - known_smart_answer_files
    unknown_files.any?
  end
end
