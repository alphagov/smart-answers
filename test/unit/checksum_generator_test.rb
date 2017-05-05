require_relative '../test_helper'

class ChecksumGeneratorTest < ActiveSupport::TestCase
  context 'update' do
    should "error if the checksum file doesn't exist" do
      SmartAnswerTestHelper.any_instance.stubs(:files_checksum_data_exists?).returns(false)

      exception = assert_raises RuntimeError do
        ChecksumGenerator.update('foo')
      end

      assert_equal(
        exception.message,
        'No checksum data found, use checksums:add_files[foo] to generate it'
      )
    end

    should 'write_files_checksum is called' do
      SmartAnswerTestHelper.any_instance.stubs(:files_checksum_data_exists?).returns(true)
      SmartAnswerTestHelper.any_instance.stubs(:read_files_checksums).returns({})
      SmartAnswerFiles.any_instance.stubs(:existing_paths).returns([])

      SmartAnswerTestHelper.any_instance.expects(:write_files_checksum).once

      ChecksumGenerator.update('foo')
    end

    should 'return the output path' do
      SmartAnswerTestHelper.any_instance.stubs(:files_checksum_data_exists?).returns(true)
      SmartAnswerTestHelper.any_instance.stubs(:read_files_checksums).returns({})
      SmartAnswerFiles.any_instance.stubs(:existing_paths).returns([])
      SmartAnswerTestHelper.any_instance.stubs(:write_files_checksum)
      SmartAnswerTestHelper.any_instance.stubs(:files_checksum_path).returns('/bar')

      output_path = ChecksumGenerator.update('foo')

      assert_equal output_path, '/bar'
    end
  end
end
