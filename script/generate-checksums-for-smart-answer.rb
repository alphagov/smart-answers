unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name> <additional-flow-file-paths>"
  exit 1
end

flow_helper = SmartAnswerTestHelper.new(flow_name)

existing_additional_flow_file_paths = []
if flow_helper.files_checksum_data_exists?
  existing_checksum_data = flow_helper.read_files_checksums
  existing_additional_flow_file_paths = existing_checksum_data.keys
end

additional_flow_file_paths = ARGV + existing_additional_flow_file_paths
flow_files = SmartAnswerFiles.new(flow_name, *additional_flow_file_paths)

abort "No files detected, did you misspell the smartanswer name? (#{flow_name})" if flow_files.empty?

hasher = SmartAnswerHasher.new(flow_files.existing_paths)

flow_helper.write_files_checksum(hasher)

puts "Checksum data written to #{flow_helper.files_checksum_path}"
