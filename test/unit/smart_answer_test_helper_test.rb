require_relative '../test_helper'

class SmartAnswerTestHelperTest < ActiveSupport::TestCase
  setup do
    @flow_name = 'flow-name'
    @temp_file = Tempfile.new('filename')
    @smart_answer_files = stub(existing_paths: [@temp_file.path], paths: [@temp_file.path])
    SmartAnswerFiles.stubs(:new).with(@flow_name).returns(@smart_answer_files)
    @test_helper = SmartAnswerTestHelper.new(@flow_name)
  end

  teardown do
    @temp_file.unlink
    @temp_file.close
  end

  should 'return true if RUN_REGRESSION_TESTS is true' do
    ENV['RUN_REGRESSION_TESTS'] = 'true'
    assert_equal true, @test_helper.run_regression_tests?
  end

  should 'return true if RUN_REGRESSION_TESTS is equal to this flow name' do
    ENV['RUN_REGRESSION_TESTS'] = @flow_name
    assert_equal true, @test_helper.run_regression_tests?
  end

  should 'return false if RUN_REGRESSION_TESTS is equal to a different flow name' do
    ENV['RUN_REGRESSION_TESTS'] = 'another-flow-name'
    assert_equal false, @test_helper.run_regression_tests?
  end

  should 'return true when more source files have been added to the Smart Answer' do
    @smart_answer_files.stubs(paths: [@temp_file.path, '/path/to/new/file'])
    assert_equal true, @test_helper.run_regression_tests?
  end
end
