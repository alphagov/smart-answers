require_relative '../test_helper'

class SmartAnswerFilesTest < ActiveSupport::TestCase
  context 'when provided with a misspelled flow name' do
    should 'be empty' do
      files = SmartAnswerFiles.new("i-dont-exist")
      assert files.empty?
      assert_equal [], files.existing_paths
    end
  end

  context 'with no additional files' do
    setup do
      @flow_name = 'flow-name'
      @files = SmartAnswerFiles.new(@flow_name)
    end

    should 'return an array of paths to the flow file, template file and two test data files' do
      assert_equal 4, @files.paths.length
    end

    should 'include the relative path to the smart answer flow ruby file' do
      expected_path = File.join('lib', 'smart_answer_flows', "#{@flow_name}.rb")
      assert_equal true, @files.paths.include?(expected_path)
    end

    should 'include the relative path to the smart answer yaml template file' do
      expected_path = File.join('lib', 'smart_answer_flows', 'locales', 'en', "#{@flow_name}.yml")
      assert_equal true, @files.paths.include?(expected_path)
    end

    should 'include the relative path to the question and responses test data path' do
      expected_path = File.join('test', 'data', "#{@flow_name}-questions-and-responses.yml")
      assert_equal true, @files.paths.include?(expected_path)
    end

    should 'include the relative path to the responses and expected outcomes test data path' do
      expected_path = File.join('test', 'data', "#{@flow_name}-responses-and-expected-results.yml")
      assert_equal true, @files.paths.include?(expected_path)
    end
  end

  context 'with erb template files' do
    should 'include the path of erb templates' do
      flow_name = 'flow-name'
      smart_answer_with_erb_templates(flow_name) do |erb_template_files|
        smart_answer_files = SmartAnswerFiles.new(flow_name)
        erb_template_files.each do |file|
          expected_path = file.path.relative_path_from(Rails.root)
          assert_equal true, smart_answer_files.paths.include?(expected_path)
        end
      end
    end
  end

  context 'with additional files' do
    should 'return relative paths to the additional files' do
      with_temporary_file_in_project do |file|
        absolute_path = File.expand_path(file)
        files = SmartAnswerFiles.new('flow-name', absolute_path)

        expected_path = Pathname.new(absolute_path).relative_path_from(Rails.root).to_s
        assert_equal true, files.paths.include?(expected_path)
      end
    end

    should 'remove duplicate paths' do
      with_temporary_file_in_project do |file|
        absolute_path = File.expand_path(file)
        files = SmartAnswerFiles.new('flow-name', absolute_path, absolute_path)

        assert_equal files.paths.uniq.length, files.paths.length
      end
    end

    should "ignore files that don't exist" do
      non_existent_file = 'path/to/non-existent/file'
      files = SmartAnswerFiles.new('flow-name', non_existent_file)

      assert_equal false, files.paths.include?(non_existent_file)
    end
  end

  private

  def with_temporary_file_in_project
    begin
      file = Tempfile.new('temporary-file', Rails.root)
      yield file
    ensure
      file.unlink
      file.close
    end
  end

  def smart_answer_with_erb_templates(flow_name)
    begin
      erb_template_directory = Rails.root.join('lib', 'smart_answer_flows', flow_name)
      FileUtils.mkdir_p(erb_template_directory)

      files = (1..2).collect do |count|
        Tempfile.new(["flow_name-#{count}", '.erb'], erb_template_directory)
      end

      partial_dir = FileUtils.mkdir_p(erb_template_directory.join('partials'))
      files << Tempfile.new(["partial", '.erb'], partial_dir.first)

      yield files
    ensure
      FileUtils.remove_dir(erb_template_directory, force = true)
      files.each do |file|
        file.unlink
        file.close
      end
    end
  end
end
