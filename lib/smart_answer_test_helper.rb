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

  def self.configurations
    yaml = File.read(data_path.join('configurations.yml'))
    YAML.load(yaml)
  end

  def self.default_configuration
    configurations.fetch('default')
  end

  def initialize(flow_name)
    @flow_name = flow_name
  end

  def configuration
    default = self.class.default_configuration
    self.class.configurations.fetch(@flow_name, default)
  end

  def current_time
    configuration.fetch(:current_time)
  end

  def run_regression_tests?
    explicitly_run_all_regression_tests? ||
      explicitly_run_this_regression_test?
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
    filename = "#{responses.pop}.txt"
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

  def explicitly_run_this_regression_test?
    ENV['RUN_REGRESSION_TESTS'] == @flow_name
  end

  def explicitly_run_all_regression_tests?
    ENV['RUN_REGRESSION_TESTS'] == 'true'
  end
end
