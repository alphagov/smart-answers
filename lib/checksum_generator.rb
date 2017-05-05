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

  def self.add_files(flow_name, arguments)
    flow_helper = SmartAnswerTestHelper.new(flow_name)

    existing_files = []
    if flow_helper.files_checksum_data_exists?
      existing_files = flow_helper.read_files_checksums.keys
    end

    flow_files = SmartAnswerFiles.new(
      flow_name,
      *existing_files,
      *files_from_arguments(arguments)
    )

    abort "No files detected for #{flow_name} "if flow_files.empty?

    hasher = SmartAnswerHasher.new(flow_files.existing_paths)
    flow_helper.write_files_checksum(hasher)

    flow_helper.files_checksum_path
  end

  def self.files_from_arguments(arguments)
    arguments.each do |file|
      if File.directory? file
        raise "#{file} is a directory, and only files are supported. Use a glob, e.g. #{file}/** to add files within that directory"
      end
    end

    arguments.flat_map do |arg|
      files = Dir.glob(arg)

      raise "No files matching #{arg}" if files.empty?

      # Remove any directories added by globs, as they cannot be
      # hashed
      files.reject { |file| File.directory?(file) }
    end
  end
end
