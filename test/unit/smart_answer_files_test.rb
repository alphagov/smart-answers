require_relative '../test_helper'

class SmartAnswerFilesTest < ActiveSupport::TestCase
  context 'with no additional files' do
    setup do
      @flow_name = 'flow-name'
      @files = SmartAnswerFiles.new(@flow_name)
    end

    should 'return an array of paths to the flow file and template file' do
      assert_equal 2, @files.paths.length
    end

    should 'include the relative path to the smart answer flow ruby file' do
      expected_path = File.join('lib', 'smart_answer_flows', "#{@flow_name}.rb")
      assert_equal true, @files.paths.include?(expected_path)
    end

    should 'include the relative path to the smart answer yaml template file' do
      expected_path = File.join('lib', 'smart_answer_flows', 'locales', 'en', "#{@flow_name}.yml")
      assert_equal true, @files.paths.include?(expected_path)
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
end
