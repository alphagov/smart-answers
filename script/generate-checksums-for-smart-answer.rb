unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name> <additional-flow-file-paths>"
  exit 1
end

additional_flow_file_paths = ARGV
flow_files = SmartAnswerFiles.new(flow_name, *additional_flow_file_paths)

hasher = SmartAnswerHasher.new(flow_files.paths)

data_path = Rails.root.join('test', 'data', "#{flow_name}-files.yml")
File.open(data_path, 'w') do |file|
  hasher.write_checksum_data(file)
end

puts "Checksum data written to #{data_path}"
