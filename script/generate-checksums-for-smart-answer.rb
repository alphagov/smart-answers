unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name> <additional-flow-file-paths>"
  exit 1
end

flow_file_paths = SmartAnswerFiles.new(flow_name).paths
additional_flow_file_paths = ARGV

unique_flow_file_paths = (flow_file_paths + additional_flow_file_paths).uniq
hasher = SmartAnswerHasher.new(unique_flow_file_paths)

data_path = Rails.root.join('test', 'data', "#{flow_name}-files.yml")
File.open(data_path, 'w') do |file|
  hasher.write_checksum_data(file)
end

puts "Checksum data written to #{data_path}"
