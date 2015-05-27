require_relative '../test_helper'

class SmartAnswerTestHelperTest < ActiveSupport::TestCase
  setup do
    @temp_file = Tempfile.new('filename')
    @hasher = SmartAnswerHasher.new([@temp_file.path])
    @test_helper = SmartAnswerTestHelper.new('flow-name')
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
end
