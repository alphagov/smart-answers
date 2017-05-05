namespace :checksums do
  desc "Update checksums for smart answer flows"
  task update: :environment do |_, args|
    available_flows = SmartAnswer::FlowRegistry.new.available_flows

    if args.extras.empty?
      flow_names = available_flows
    else
      flow_names = args.extras
    end

    unknown_flows = flow_names - available_flows
    if unknown_flows.any?
      raise "The following flows could not be found: #{unknown_flows.join(', ')}"
    end

    flow_names.each do |flow_name|
      output_path = ChecksumGenerator.update(flow_name)

      puts "Checksum data written to #{output_path}"
    end
  end

  desc "Generate or amend a checksums file for a flow"
  task :add_files, [:flow_name] => :environment do |_, args|
    flow_name = args.flow_name

    args.extras.each do |file|
      if File.directory? file
        abort "#{file} is a directory, and only files are supported. Use a glob, e.g. #{file}/** to add files within that directory"
      end
    end

    file_lists_for_arguments = args.extras.map do |arg|
      files = Dir.glob(arg)

      abort "No files matching #{arg}" if files.empty?

      # Remove any directories added by globs
      files.reject { |file| File.directory?(file) }
    end

    new_files = file_lists_for_arguments.flatten

    flow_helper = SmartAnswerTestHelper.new(flow_name)

    existing_files = []
    if flow_helper.files_checksum_data_exists?
      existing_files = flow_helper.read_files_checksums.keys
    end

    flow_files = SmartAnswerFiles.new(flow_name, *existing_files, *new_files)

    abort "No files detected for #{flow_name} "if flow_files.empty?

    hasher = SmartAnswerHasher.new(flow_files.existing_paths)
    flow_helper.write_files_checksum(hasher)

    puts "Checksum data written to #{flow_helper.files_checksum_path}"
  end
end
