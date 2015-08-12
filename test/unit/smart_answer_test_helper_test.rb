require_relative '../test_helper'

class SmartAnswerTestHelperTest < ActiveSupport::TestCase
  context 'when checksum data is present' do
    setup do
      @flow_name = 'flow-name'
      @temp_file = Tempfile.new('filename')
      @smart_answer_files = stub(existing_paths: [@temp_file.path], paths: [@temp_file.path])
      SmartAnswerFiles.stubs(:new).with(@flow_name).returns(@smart_answer_files)
      @hasher = SmartAnswerHasher.new(@smart_answer_files.paths)
      @test_helper = SmartAnswerTestHelper.new(@flow_name)
      @test_helper.write_files_checksum(@hasher)
    end

    teardown do
      FileUtils.rm @test_helper.files_checksum_path

      @temp_file.unlink
      @temp_file.close
    end

    should 'return false if the file checksums have not changed' do
      assert_equal false, @test_helper.run_regression_tests?
    end

    should 'return true if the file checksums have changed' do
      @temp_file.rewind
      @temp_file.puts('new-content')
      @temp_file.rewind

      assert_equal true, @test_helper.run_regression_tests?
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

  context 'when checksum data is missing' do
    should 'return true if the checksum data is missing' do
      test_helper = SmartAnswerTestHelper.new('flow-name')
      assert_equal true, test_helper.run_regression_tests?
    end
  end
end
