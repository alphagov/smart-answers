module ChecksumGenerator
  def self.update(flow_name)
    flow_helper = SmartAnswerTestHelper.new(flow_name)

    unless flow_helper.files_checksum_data_exists?
      raise "No checksum data found, use checksums:add_files[#{flow_name}] to generate it"
    end

    flow_files = SmartAnswerFiles.new(flow_name, *flow_helper.read_files_checksums.keys)
    hasher = SmartAnswerHasher.new(flow_files.existing_paths)
    flow_helper.write_files_checksum(hasher)

    flow_helper.files_checksum_path
  end
end
