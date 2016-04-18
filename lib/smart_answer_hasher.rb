class SmartAnswerHasher
  class FileNotFound < StandardError; end

  def initialize(flow_file_paths)
    @flow_file_paths = flow_file_paths
    ensure_all_files_exist
    calculate_checksum_data
  end

  def write_checksum_data(io)
    io.puts(@checksum_data.to_yaml)
  end

private

  def ensure_all_files_exist
    @flow_file_paths.each do |path|
      raise FileNotFound.new(path) unless File.exist?(path)
    end
  end

  def calculate_checksum_data
    @checksum_data = @flow_file_paths.inject({}) do |hash, file_path|
      file_content = File.read(file_path)
      hash[file_path] = Digest::MD5.hexdigest(file_content)
      hash
    end
  end
end
