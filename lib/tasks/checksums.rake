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
    raise "The flow name must be specified" if args.flow_name.nil?

    output_path = ChecksumGenerator.add_files(args.flow_name, args.extras)

    puts "Checksum data written to #{output_path}"
  end
end
