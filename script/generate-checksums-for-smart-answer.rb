unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name> <additional-flow-file-paths>"
  exit 1
end

additional_flow_file_paths = ARGV
flow_files = SmartAnswerFiles.new(flow_name, *additional_flow_file_paths)

hasher = SmartAnswerHasher.new(flow_files.paths)

flow_helper = SmartAnswerTestHelper.new(flow_name)
flow_helper.write_files_checksum(hasher)

puts "Checksum data written to #{flow_helper.files_checksum_path}"
