unless ARGV.length >= 2
  puts "Usage: #{__FILE__} <flow-name> <flow-file-paths>"
  exit 1
end

flow_name = ARGV.shift
flow_file_paths = ARGV

hasher = SmartAnswerHasher.new(flow_file_paths)

data_path = Rails.root.join('test', 'data', "#{flow_name}-files.yml")
File.open(data_path, 'w') do |file|
  hasher.write_checksum_data(file)
end

puts "Checksum data written to #{data_path}"
