require_relative '../test_helper'

class SmartAnswerFilesTest < ActiveSupport::TestCase
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
